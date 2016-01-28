//
//  CollapsingArray.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 1/25/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//



///Data structure protocol designed to represent series of values which include long stretches of unchanges values
protocol ExclusiveRangeMappingProtocol:MutableCollectionType, RangeReplaceableCollectionType, CustomStringConvertible {
    typealias Element:Equatable
    typealias Index:RandomAccessIndexType,Hashable,IntegerLiteralConvertible
    var data:[RangeValuePair<Element>] {get set}
    
    var startIndex:Index {get}
    var endIndex:Index {get}
    
    //var expandedArray:[Element] {get}
    
}

extension ExclusiveRangeMappingProtocol {
    
    var startIndex:Index {
        return 0
    }
    
    var description:String {return data.description}
    
}

///expanded form generator
public struct ERMPGenerator<Element:Equatable>: GeneratorType {
    
    private var data:[RangeValuePair<Element>]
    private var nextIndex:Int
    private var dataItem:Int
    
    init(data:[RangeValuePair<Element>]){
        self.data = data
        nextIndex = 0
        dataItem = 0
    }
    mutating public func next() -> Element? {
        if nextIndex++ >= data[dataItem].endIndex {
            guard ++dataItem < self.data.count else {return nil}
        }
        return data[dataItem].value
    }
}


//
/////exclusive, full coverage interval mapping designed for short intervals
struct CollapsingArray<Element:Equatable>: ExclusiveRangeMappingProtocol, ArrayLiteralConvertible {
    typealias Index = Int
    var data:[RangeValuePair<Element>] = []
    
    var endIndex:Index { return data.last?.endIndex ?? 0 }
    
    
    
    typealias Generator = ERMPGenerator<Element>
    func generate() -> Generator {
        return Generator(data: data)
    }
    
    var array:[Element] {return self.map({return $0})}
    
    
    subscript(position:Index)->Element{
        get {
            guard let di = dataIndexForIndex(position) else {fatalError("CollapsingArray: out of bounds index \(position), for CA length \(self.endIndex)")}
            return data[di].value
        }
        set {
            
            guard let di = dataIndexForIndex(position) else {fatalError("CollapsingArray: out of bounds index \(position)")}
            guard data[di].value != newValue else {return}
            if position == data[di].startIndex {
                if data[di].endIndex == position + 1 {
                    data[di] = RangeValuePair(value: newValue, range: data[di].range)
                } else {
                    self.splitRangeAtIndex(position + 1)
                    data[di] = RangeValuePair(value: newValue, startIndex: position, endIndex:position + 1)
                }
            } else if position == data[di].endIndex - 1 {
                self.splitRangeAtIndex(position)
                data[di + 1] = RangeValuePair(value: newValue, startIndex:position, endIndex:position + 1)
                condenseAroundDataIndex(di + 1)
                return
            } else {
                //middle insert
                self.splitRangeAtIndex(position)
                self.splitRangeAtIndex(position + 1)
                data[di + 1] = RangeValuePair(value: newValue, startIndex: position, endIndex:position + 1)
                return
            }
            condenseAroundDataIndex(di)
        }
        
    }
    
    
    
    init() {}
    
    init(arrayLiteral elements: Element...) {
        self.init(array: elements,startingIndex: 0)
    }
    
    
    init(array:[Element]){
        self.init(array: array,startingIndex: 0)
    }
    
    
    ///startIndex can never be non-zero in actual external use but we need it non-zero for internal operations like inserts where we don't want to go through the extra step of adjusting indices
    private init(array:[Element], startingIndex si:Int){
        var currentIndex = 0
        while currentIndex < array.count{
            let thisVal = array[currentIndex]
            var rangeEnded = false
            for i in currentIndex..<array.count {
                let val = array[i]
                if val != thisVal {
                    data.append(RangeValuePair(value: thisVal, startIndex: currentIndex + si, endIndex: i + si))
                    currentIndex = i
                    rangeEnded = true
                    break
                }
            }
            if !rangeEnded {
                data.append(RangeValuePair(value: thisVal, startIndex: currentIndex + si, endIndex: array.count + si))
                break
            }
        }
    }
    
    init(repeatedValue:Element, count:Int){
        data.append(RangeValuePair(value: repeatedValue, startIndex: 0, endIndex: count))
    }
    
    
    //////////////
    //RRCP conformance
    mutating func replaceRange<C : CollectionType where C.Generator.Element == Generator.Element>(subRange: Range<Index>, with newElements: C) {
        self.removeRange(subRange)
        self.insertContentsOf(newElements, at: subRange.startIndex)
        
    }
    
    //should cleanup removerange, insertContentsOf, append, etc for performance
    
    mutating func insert(newElement: Generator.Element, atIndex i: Index) {
        let ca = CollapsingArray(array: [newElement])
        self.insertContentsOf(ca, at: i)
    }
    
    mutating func insertContentsOf<C : CollectionType where C.Generator.Element == Generator.Element>(newElements: C, at i: Index) {
        guard i != self.endIndex else {self.appendContentsOf(newElements); return}
        guard let di = dataIndexForIndex(i) else {fatalError("insert out of bounds")}
        //cases: if non CollapsingArray, make it a collapsing array
        var ca:CollapsingArray!
        let newCount = newElements.count as! Int
        if newElements is CollapsingArray {
            ca = newElements as! CollapsingArray
            ca.modifyIndecesAtOrPastIndex(0, modifyBy: i)
        }
        else {
            ca = CollapsingArray(array: Array(newElements), startingIndex: i)
        }

        let diInsertionPoint = self.splitRangeAtIndex(i) ? di + 1 : di
        self.modifyIndecesAtOrPastIndex(i, modifyBy: newCount)
        data.insertContentsOf(ca.data, at:diInsertionPoint)
        
        self.condenseAroundDataIndex(diInsertionPoint)
    }
    
    
    
    mutating func removeRange(subRange: Range<Index>) {
        //modify/split start of existing range
        guard subRange.startIndex >= 0 && subRange.endIndex <= self.endIndex  else {fatalError("removeRange: out of bounds: \(subRange), from \(self.startIndex..<self.endIndex)")}
        guard subRange.startIndex != subRange.endIndex else {return}
        splitRangeAtIndex(subRange.startIndex)
        splitRangeAtIndex(subRange.endIndex)
        let startingDi = dataIndexForIndex(subRange.startIndex)!
        var endingDi = startingDi + 1
        for i in (startingDi + 1)..<data.count {
            if data[i].startIndex < subRange.endIndex {
                endingDi = i + 1
            }
        }
        data.removeRange(startingDi..<endingDi)
        
        
        modifyIndecesAtOrPastIndex(subRange.startIndex, modifyBy: -subRange.count)
        
        if startingDi - 1 > 0 && data.count > startingDi {
            condenseIndexWithFollowing(startingDi - 1)
        }
        
    }
    
    mutating func append(newElement: Generator.Element) {
        if newElement == data.last?.value {
            data[data.count - 1].endIndex += 1
        } else {
            let startingEndIndex = self.endIndex
            data.append(RangeValuePair(value: newElement, startIndex: startingEndIndex, endIndex: startingEndIndex + 1))
            let dc = data.count
            if dc > 1 {
                self.condenseIndexWithFollowing(dc - 2)
            }
        }
    }
    
    mutating func appendContentsOf<S : SequenceType where S.Generator.Element == Generator.Element>(newElements: S) {
        let ca = CollapsingArray(array: Array(newElements), startingIndex: self.endIndex)
        let lastDi = self.data.count - 1
        data.appendContentsOf(ca.data)
        if lastDi > 0 && self.data.count > 1{
            condenseIndexWithFollowing(lastDi)
        }
    }
 ////////////////////////////
    
    mutating func appendRepeatedValue(value:Element, count:Int){
        let rvp = RangeValuePair(value: value, range:NSRange(location:self.endIndex, length: count))
        data.append(rvp)
        if data.count > 1 {
            condenseIndexWithFollowing(data.count - 2)
        }
    }
    
    mutating func setValueForRange(value:Element, range:Range<Int>){
        guard range.startIndex <= self.endIndex else {
            fatalError("setValueForRange: out of bounds: newRange: \(range), existing range: \(self.startIndex..<self.endIndex)")
        }
        guard range.startIndex < range.endIndex else {return}
        
        //cases: range extends past or range contained in
        let newRVP = RangeValuePair(value: value, range:range)
        if range.startIndex == self.endIndex {
            data.append(newRVP)
        } else {
            if range.endIndex <= self.endIndex {
                replaceRange(range, with: CollapsingArray(repeatedValue: value, count: range.count))
            } else {
                removeRange(range.startIndex..<self.endIndex)
                data.append(newRVP)
            }
        }
        if data.count > 1 {
            condenseIndexWithFollowing(data.count - 2)
        }
    }
    
    func rvp(dataIndex:Int)->(range:Range<Int>,value:Element){
        return (range:data[dataIndex].range, value:data[dataIndex].value)
    }
    
    ///Returns a copy of a slice with its indeces zeroed
    func subRange(subRange:Range<Int>)->CollapsingArray<Element>{
        guard subRange.startIndex >= 0 && subRange.endIndex <= self.endIndex  else {fatalError("removeRange: out of bounds: \(subRange), from \(self.startIndex..<self.endIndex)")}
        var newSub = CollapsingArray<Element>()
        guard subRange.startIndex != subRange.endIndex else {return newSub}
        
        ///get a copy of the raw slice
        let startingDi = dataIndexForIndex(subRange.startIndex)!
        let endingDi =  dataIndexForIndex(subRange.endIndex - 1)!
        newSub.data.appendContentsOf(self.data[startingDi...endingDi])
        
        //clean up the ends which may go out of the subrange
        newSub.splitRangeAtIndex(subRange.startIndex)
        newSub.splitRangeAtIndex(subRange.endIndex)
        if newSub.data.last!.startIndex == subRange.endIndex {newSub.data.removeAtIndex(newSub.count - 1)}
        if newSub.data.first!.endIndex == subRange.startIndex {newSub.data.removeFirst()}
        
        //reindex
        for i in 0..<newSub.data.count {
            newSub.data[i].reindex(-subRange.startIndex)
        }
        
        return newSub
    }
    
    /////////////////////////////////
    /// Internal helpers
    
    ///splits a range object between index and index - 1 to facilitate inserts and deletes. Returns true if a split was performed (meaning self.data gained 1 element), false otherwise
    private mutating func splitRangeAtIndex(index:Int)->Bool{
        guard index != 0 && index != self.endIndex else {return false}
        guard let di = dataIndexForIndex(index) else {fatalError("insert out of bounds")}
        if index == data[di].startIndex {
            return false
        } else {
            let firstHalf = RangeValuePair(value: data[di].value, startIndex: data[di].startIndex, endIndex: index)
            let secondHalf = RangeValuePair(value: data[di].value, startIndex: index, endIndex: data[di].endIndex)
            data[di] = firstHalf
            data.insert(secondHalf, atIndex: di + 1)
            return true
        }
        
    }
    
    private func dataIndexForIndex(position:Int)->Int?{
        for (i,rvp) in data.enumerate() {
            if position >= rvp.startIndex && position < rvp.endIndex {
                return i
            }
        }
        return nil
    }
    
    mutating private func modifyIndecesAtOrPastIndex(index:Int, modifyBy:Int){
        //guard let baseDi = dataIndexForIndex(index) else {return}
        //for var rvp in data.reverse() {
        for di in (0..<data.count).reverse() {
            //let starting = data[di]
            if data[di].endIndex <= index {return}
            data[di].endIndex += modifyBy
            if data[di].startIndex < index {return}
            data[di].startIndex += modifyBy
            //            print("\(starting) => \(data[di])")
        }
    }
    
    
    ///If the data contained in the rvp at di equals that of the data in (di + 1) then the ranges will be merged
    mutating private func condenseIndexWithFollowing(di:Int){
        if data[di].value == data[di + 1].value {
            data[di] = RangeValuePair(value: data[di].value, range: data[di].startIndex..<data[di + 1].endIndex)
            data.removeAtIndex(di + 1)
        }
    }
    
    mutating private func condenseAroundDataIndex(dataIndex:Int){
        guard data.count > 1 else {return}
        if dataIndex == 0 {
            condenseIndexWithFollowing(0)
        } else if dataIndex == data.count - 1 {
            condenseIndexWithFollowing(dataIndex - 1)
        } else {
            condenseIndexWithFollowing(dataIndex)
            condenseIndexWithFollowing(dataIndex - 1)
        }
    }
    
    private mutating func condenseAll(){
        var shouldRepeat = true
        while shouldRepeat {
            let startingRVPCount = data.count
            guard startingRVPCount > 1 else {return}
            shouldRepeat = false
            
            for i in (0..<(startingRVPCount - 1)).reverse() {
                condenseIndexWithFollowing(i)
            }
        }
        
    }
    
    ///Internal validator. This isn't intended for use in production.
    func validate()->Bool{
        guard self.data.count > 0 else {return true}
        guard self.data[0].startIndex == 0 else {print("validate failed: nonZero start: \(data[0])"); return false}
        for i in 1..<data.count {
            if data[i].startIndex != data[i - 1].endIndex {
                print("validate failed: start doesn't line up with previous end: \(data[i - 1]), \(data[i])")
                return false
            } else if data[i].value == data[(i - 1)].value {
                print("validate failed: adjacent matching items: \(data[i - 1]), \(data[i])")
                return false
            }
        }
        return true
    }
    
}

extension CollapsingArray where Element:OptionSetTypeWithIntegerRawValue {
    //this should be used to convert the items to and from portable format (bitcode)
    
    var asRVPArray:[[Int]] {return data.map({return [$0.startIndex,$0.endIndex,$0.value.rawValue]})}
    
//    init!<OptionSetTypeWithIntegerRawValue>(rvpArray:[[Int]]){
//        guard rvpArray.first?.startIndex == 0 else {return nil}
//        for item in rvpArray {
//            guard item.count == 3 else {print("init!(rvpArray:[[Int]]):  bad data"); return nil}
//            data.append(RangeValuePair(value: Element(rawValue: item[2]), startIndex: item[0], endIndex: item[1]))
//        }
//        guard validate() else {return nil}
//    }
    
}

//extension CollapsingArray {
//    
//    static func iaBaseAttsArrayFromIntArrays(rvpArray:[[Int]])->CollapsingArray<IABaseAttributes>{
//        var ca = CollapsingArray<IABaseAttributes>()
//        //guard rvpArray.first?.startIndex == 0 else {return nil}
//        for item in rvpArray {
//            //guard item.count == 3 else {print("init!(rvpArray:[[Int]]):  bad data"); return nil}
//            ca.data.append(RangeValuePair(value: IABaseAttributes(rawValue:item[2]), startIndex: item[0], endIndex: item[1]))
//        }
//        //guard ca.validate() else {return nil}
//        return ca
//    }
//    
//
//}

//extension CollapsingArray {
//    static func binAttZip(bins bins:CollapsingArray<Int>,atts:CollapsingArray<IABaseAttributes>)->CollapsingArray<BinAttPair>{
//        let totalLength = bins.count
//        guard totalLength == atts.count else {fatalError("binAttZip: bins.count != atts.count ")}
//        guard totalLength > 0 else {return CollapsingArray<BinAttPair>()}
//        var baps = CollapsingArray<BinAttPair>()
//        var currentIndex = 0
//        var binDi = 0
//        var attsDi = 0
//        while currentIndex < totalLength {
//            let binAttPair = BinAttPair(bin: bins.data[binDi].value, atts: atts.data[attsDi].value)
//            let binEnd = bins.data[binDi].endIndex
//            let attsEnd = atts.data[attsDi].endIndex
//            var endIndex:Int!
//            if binEnd < attsEnd {
//                endIndex = binEnd
//                binDi++
//            } else if attsEnd < binEnd {
//                endIndex = attsEnd
//                attsDi++
//            } else {
//                endIndex == attsEnd
//                binDi++
//                attsDi++
//            }
//            let rvp = RangeValuePair(value: binAttPair, startIndex: currentIndex, endIndex: endIndex)
//            currentIndex = endIndex
//            baps.data.append(rvp)
//        }
//        return baps
//    }
//}
//
//struct BinAttPair:Hashable {
//    let bin:Int
//    let atts:IABaseAttributes
//    
//    init(bin:Int, atts:IABaseAttributes){
//        self.bin = bin
//        self.atts = atts
//    }
//    
//    var hashValue:Int {return bin.hashValue * 0x1000 + atts.hashValue}
//}
//
//func ==(lhs:BinAttPair, rhs:BinAttPair)->Bool{
//    return lhs.hashValue == rhs.hashValue
//}

