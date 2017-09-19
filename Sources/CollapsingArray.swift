//
//  CollapsingArray.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 1/25/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import Foundation

///Data structure protocol designed to represent series of values which include long stretches of unchanges values. Arguably a linked list might perform better for the same purposes though it shouldn't matter for the length of IAStrings we're using. This maps more cleanly to the format we use in the JSON representations.
protocol ExclusiveRangeMappingProtocol:MutableCollection, RangeReplaceableCollection, CustomStringConvertible where Element: Equatable, Index: Strideable, Index: Hashable, Index: ExpressibleByIntegerLiteral {
    
    var data:[RangeValuePair<Element>] {get set}
    
    var startIndex:Index {get}
    var endIndex:Index {get}
    
}

extension ExclusiveRangeMappingProtocol {
    
    public var startIndex:Index {
        return 0
    }
    
    public var description:String {return data.description}
    
}

///expanded form generator
public struct ERMPGenerator<Element:Equatable>: IteratorProtocol {
    
    fileprivate var data:[RangeValuePair<Element>]
    fileprivate var nextIndex:Int
    fileprivate var dataItem:Int
    
    init(data:[RangeValuePair<Element>]){
        self.data = data
        nextIndex = 0
        dataItem = 0
    }
    mutating public func next() -> Element? {
        //        if nextIndex++ >= data[dataItem].endIndex {
        //            guard ++dataItem < self.data.count else {return nil}
        //        }
        if nextIndex >= data[dataItem].endIndex {
            nextIndex += 1
            dataItem += 1
            guard dataItem < self.data.count else {return nil}
        } else {
            nextIndex += 1
        }
        return data[dataItem].value
    }
}


/**Data structure designed to represent series of values which include long stretches of unchanges values (whcih must conform to equatable). This stores an array of RangeValuePairs which are structs containing a CountableRange<Int> representing the index as seen by the user and a value. The ranges do not intersect but the union of the ranges covers the entire index space of the Collapsing Array. This data structure will be more efficient for handling long stretches of unchanged values than would be a plain array, though a linked list might perform better for the same purposes. It shouldn't matter for the length of IAStrings we're using. This maps more cleanly to the format we use in the JSON representations.
 */
public struct CollapsingArray<Element:Equatable>: ExclusiveRangeMappingProtocol, ExpressibleByArrayLiteral {
    
    
    
    
    public typealias Index = Int
    var data:[RangeValuePair<Element>] = []
    
    public var endIndex:Index { return data.last?.endIndex ?? 0 }
    
    
    
    public typealias Iterator = ERMPGenerator<Element>
    public func makeIterator() -> Iterator {
        return Iterator(data: data)
    }
    
    var array:[Element] {return self.map({return $0})}
    
    
    public subscript(position:Index)->Element{
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
    
    
    
    public init() {}
    
    public init(arrayLiteral elements: Element...) {
        self.init(array: elements,startingIndex: 0)
    }
    
    
    init(array:[Element]){
        self.init(array: array,startingIndex: 0)
    }
    
    
    ///startIndex can never be non-zero in actual external use but we need it non-zero for internal operations like inserts where we don't want to go through the extra step of adjusting indices
    fileprivate init(array:[Element], startingIndex si:Int){
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
    
    /// Returns the position immediately after the given index.
    ///
    /// - Parameter i: A valid index of the collection. `i` must be less than
    ///   `endIndex`.
    /// - Returns: The index value immediately after `i`.
    public func index(after i: Int) -> Int {
        return i + 1
    }
    
    /// Replaces the specified subrange of elements with the given collection.
    ///
    /// This method has the effect of removing the specified range of elements
    /// from the collection and inserting the new elements at the same location.
    /// The number of new elements need not match the number of elements being
    /// removed.
    ///
    /// In this example, three elements in the middle of an array of integers are
    /// replaced by the five elements of a `Repeated<Int>` instance.
    ///
    ///      var nums = [10, 20, 30, 40, 50]
    ///      nums.replaceSubrange(1...3, with: repeatElement(1, count: 5))
    ///      print(nums)
    ///      // Prints "[10, 1, 1, 1, 1, 1, 50]"
    ///
    /// If you pass a zero-length range as the `subrange` parameter, this method
    /// inserts the elements of `newElements` at `subrange.startIndex`. Calling
    /// the `insert(contentsOf:at:)` method instead is preferred.
    ///
    /// Likewise, if you pass a zero-length collection as the `newElements`
    /// parameter, this method removes the elements in the given subrange
    /// without replacement. Calling the `removeSubrange(_:)` method instead is
    /// preferred.
    ///
    /// Calling this method may invalidate any existing indices for use with this
    /// collection.
    ///
    /// - Parameters:
    ///   - subrange: The subrange of the collection to replace. The bounds of
    ///     the range must be valid indices of the collection.
    ///   - newElements: The new elements to add to the collection.
    ///
    /// - Complexity: O(*m*), where *m* is the combined length of the collection
    ///   and `newElements`. If the call to `replaceSubrange` simply appends the
    ///   contents of `newElements` to the collection, the complexity is O(*n*),
    ///   where *n* is the length of `newElements`.
    public mutating func replaceSubrange<C>(_ subrange: Range<Int>, with newElements: C) where C : Collection, C.Iterator.Element == Element {
        let fixedRange = CountableRange(subrange)
        internalRemove(fixedRange)
        insert(contentsOf: newElements, at: subrange.lowerBound)
    }
    
    
    /// Accesses a contiguous subrange of the collection's elements.
    ///
    /// The accessed slice uses the same indices for the same elements as the
    /// original collection. Always use the slice's `startIndex` property
    /// instead of assuming that its indices start at a particular value.
    ///
    /// This example demonstrates getting a slice of an array of strings, finding
    /// the index of one of the strings in the slice, and then using that index
    /// in the original array.
    ///
    ///     let streets = ["Adams", "Bryant", "Channing", "Douglas", "Evarts"]
    ///     let streetsSlice = streets[2 ..< streets.endIndex]
    ///     print(streetsSlice)
    ///     // Prints "["Channing", "Douglas", "Evarts"]"
    ///
    ///     let index = streetsSlice.index(of: "Evarts")    // 4
    ///     streets[index!] = "Eustace"
    ///     print(streets[index!])
    ///     // Prints "Eustace"
    ///
    /// - Parameter bounds: A range of the collection's indices. The bounds of
    ///   the range must be valid indices of the collection.
    public subscript(bounds: Range<Int>) -> RangeReplaceableSlice<CollapsingArray<Element>> {
        get {
            return RangeReplaceableSlice.init(base: self, bounds: bounds)
        }
        set(newValue) {
            self.replaceSubrange(bounds, with: newValue)
        }
    }
    
    //should cleanup removerange, insertContentsOf, append, etc for performance
    
    mutating public func insert(_ newElement: Iterator.Element, at i: Index) {
        let ca = CollapsingArray(array: [newElement])
        self.insert(contentsOf: ca, at: i)
    }
    
    mutating public func insert<C : Collection>(contentsOf newElements: C, at i: Index) where C.Iterator.Element == Iterator.Element {
        guard i != self.endIndex else {self.append(contentsOf: newElements); return}
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
        data.insert(contentsOf: ca.data, at:diInsertionPoint)
        
        self.condenseAroundDataIndex(diInsertionPoint)
    }
    
    ///internalRemove is used so that the ReplaceableRangeProtocol will synthesize all the range type removes from the basic replaceSubrange
    fileprivate mutating func internalRemove(_ subRange: CountableRange<Index>) {
        //modify/split start of existing range
        guard subRange.lowerBound >= 0 && subRange.upperBound <= self.endIndex  else {fatalError("removeRange: out of bounds: \(subRange), from \(self.startIndex..<self.endIndex)")}
        guard subRange.lowerBound != subRange.upperBound else {return}
        splitRangeAtIndex(subRange.lowerBound)
        splitRangeAtIndex(subRange.upperBound)
        let startingDi = dataIndexForIndex(subRange.lowerBound)!
        var endingDi = startingDi + 1
        for i in (startingDi + 1)..<data.count {
            if data[i].startIndex < subRange.upperBound {
                endingDi = i + 1
            }
        }
        data.removeSubrange(startingDi..<endingDi)
        
        
        modifyIndecesAtOrPastIndex(subRange.lowerBound, modifyBy: -subRange.count)
        
        if startingDi - 1 > 0 && data.count > startingDi {
            condenseIndexWithFollowing(startingDi - 1)
        }
    }
    
    mutating public func append(_ newElement: Iterator.Element) {
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
    
    mutating public func append<S : Sequence>(contentsOf newElements: S) where S.Iterator.Element == Iterator.Element {
        let ca = CollapsingArray(array: Array(newElements), startingIndex: self.endIndex)
        let lastDi = self.data.count - 1
        data.append(contentsOf: ca.data)
        if lastDi >= 0 && self.data.count > 1{
            condenseIndexWithFollowing(lastDi)
        }
    }
    ////////////////////////////
    
    mutating func appendRepeatedValue(_ value:Element, count:Int){
        let rvp = RangeValuePair(value: value, range:NSRange(location:self.endIndex, length: count))
        data.append(rvp)
        if data.count > 1 {
            condenseIndexWithFollowing(data.count - 2)
        }
    }
    
    mutating func setValueForRange(_ value:Element, range:CountableRange<Int>){
        guard range.lowerBound <= self.endIndex else {
            fatalError("setValueForRange: out of bounds: newRange: \(range), existing range: \(self.startIndex..<self.endIndex)")
        }
        guard range.lowerBound < range.upperBound else {return}
        
        //cases: range extends past or range contained in
        let newRVP = RangeValuePair(value: value, range:range)
        if range.lowerBound == self.endIndex {
            data.append(newRVP)
        } else {
            if range.upperBound <= self.endIndex {
                replaceSubrange(range, with: CollapsingArray(repeatedValue: value, count: range.count))
            } else {
                removeSubrange(range.lowerBound..<self.endIndex)
                data.append(newRVP)
            }
        }
        if data.count > 1 {
            condenseIndexWithFollowing(data.count - 2)
        }
    }
    
    ///Returns a tupple representing the RangeValuePair at the data index. If the data index is out of bounds then this crashes.
    func rvp(_ dataIndex:Int)->(range:CountableRange<Int>,value:Element){
        return (range:data[dataIndex].range, value:data[dataIndex].value)
    }
    
    func rvpsCoveringRange(_ range:CountableRange<Int>)->[(range:CountableRange<Int>,value:Element)]{
        guard range.count != 0 else {return []}
        var results:[(range:CountableRange<Int>,value:Element)] = []
        for rvp in self.data {
            if range.contains(rvp.startIndex) || range.contains(rvp.endIndex - 1) || rvp.range.contains(range.lowerBound) {
                results.append((range:rvp.range,value:rvp.value))
            }
        }
        return results
    }
    
    ///Returns a copy of a slice with its indeces zeroed
    func subRange(_ subRange:CountableRange<Int>)->CollapsingArray<Element>{
        guard subRange.lowerBound >= 0 && subRange.upperBound <= self.endIndex  else {fatalError("removeRange: out of bounds: \(subRange), from \(self.startIndex..<self.endIndex)")}
        var newSub = CollapsingArray<Element>()
        guard subRange.lowerBound != subRange.upperBound else {return newSub}
        
        ///get a copy of the raw slice
        let startingDi = dataIndexForIndex(subRange.lowerBound)!
        let endingDi =  dataIndexForIndex(subRange.upperBound - 1)!
        newSub.data.append(contentsOf: self.data[startingDi...endingDi])
        
        //clean up the ends which may go out of the subrange
        newSub.splitRangeAtIndex(subRange.lowerBound)
        newSub.splitRangeAtIndex(subRange.upperBound)
        if newSub.data.last!.startIndex == subRange.upperBound {newSub.data.removeLast()}
        if newSub.data.first!.endIndex == subRange.lowerBound {newSub.data.removeFirst()}
        
        //reindex
        for i in 0..<newSub.data.count {
            newSub.data[i].reindex(-subRange.lowerBound)
        }
        
        return newSub
    }
    
    /////////////////////////////////
    /// Internal helpers
    
    ///splits a range object between index and index - 1 to facilitate inserts and deletes. Returns true if a split was performed (meaning self.data gained 1 element), false otherwise
    @discardableResult fileprivate mutating func splitRangeAtIndex(_ index:Int)->Bool{
        guard index != 0 && index != self.endIndex else {return false}
        guard let di = dataIndexForIndex(index) else {fatalError("insert out of bounds")}
        if index == data[di].startIndex {
            return false
        } else {
            let firstHalf = RangeValuePair(value: data[di].value, startIndex: data[di].startIndex, endIndex: index)
            let secondHalf = RangeValuePair(value: data[di].value, startIndex: index, endIndex: data[di].endIndex)
            data[di] = firstHalf
            data.insert(secondHalf, at: di + 1)
            return true
        }
        
    }
    
    fileprivate func dataIndexForIndex(_ position:Int)->Int?{
        for (i,rvp) in data.enumerated() {
            if position >= rvp.startIndex && position < rvp.endIndex {
                return i
            }
        }
        return nil
    }
    
    mutating fileprivate func modifyIndecesAtOrPastIndex(_ index:Int, modifyBy:Int){
        //guard let baseDi = dataIndexForIndex(index) else {return}
        //for var rvp in data.reverse() {
        for di in (0..<data.count).reversed() {
            //let starting = data[di]
            if data[di].endIndex <= index {return}
            data[di].endIndex += modifyBy
            if data[di].startIndex < index {return}
            data[di].startIndex += modifyBy
            //            print("\(starting) => \(data[di])")
        }
    }
    
    
    ///If the data contained in the rvp at di equals that of the data in (di + 1) then the ranges will be merged
    mutating fileprivate func condenseIndexWithFollowing(_ di:Int){
        if data[di].value == data[di + 1].value {
            data[di] = RangeValuePair(value: data[di].value, range: data[di].startIndex..<data[di + 1].endIndex)
            data.remove(at: di + 1)
        }
    }
    
    mutating fileprivate func condenseAroundDataIndex(_ dataIndex:Int){
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
    
    fileprivate mutating func condenseAll(){
        var shouldRepeat = true
        while shouldRepeat {
            let startingRVPCount = data.count
            guard startingRVPCount > 1 else {return}
            shouldRepeat = false
            
            for i in (0..<(startingRVPCount - 1)).reversed() {
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


