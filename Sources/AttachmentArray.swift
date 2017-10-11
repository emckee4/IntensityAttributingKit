//
//  IAAttachmentArray.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 1/29/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import Foundation

/**
 The IAAttachmentArray is a sparse array created so that it's indexes could be adjusted easily when inserting/deleting content in the IAString. The underlying data structure is a data array containing tupples of the user facing index (loc) and the IATextAttachment (attach). Functions which interact with the index read or change the loc values of any contained LocAttach tupples.
 */
public struct IAAttachmentArray:CustomStringConvertible, Sequence {
    public typealias LocAttach = (loc:Int,attach:IATextAttachment)
    var data:[LocAttach] = []
    
    var lastLoc:Int? {return data.last?.loc}
    var count:Int {return data.count}
    
    init!(data:[LocAttach]){
        guard !data.isEmpty else {return}
        self.data = data.sorted(by: {$0.loc < $1.loc})
        for i in 0..<self.data.count - 1 {
            guard data[i].loc != data[i + 1].loc else {return nil}
        }
    }
    
    init(){}
    
    public typealias Iterator = Array<LocAttach>.Iterator
    
    public func makeIterator() -> Iterator {
        return data.makeIterator()
    }
    
    fileprivate func dataIndexForLoc(_ loc:Int)->Int?{
        for (i, item) in data.enumerated() {
            if item.loc == loc {
                return i
            }
        }
        return nil
    }
    
    public internal(set) subscript(position:Int)->IATextAttachment? {
        get{
            for item in data{
                if item.loc == position {
                    return item.attach
                }
            }
            return nil
        }
        set {
            if let attach = newValue {
                for i in 0..<data.count {
                    if data[i].loc == position {
                        data[i] = LocAttach(loc:position, attach:attach)
                        return
                    } else if data[i].loc > position {
                        data.insert(LocAttach(loc:position, attach:attach), at: i)
                        return
                    }
                }
                data.append(LocAttach(loc:position, attach:attach))
            } else {
                if let di = dataIndexForLoc(position) {
                    data.remove(at: di)
                }
            }
        }
    }
    
    
    mutating func modifyIndecesAtOrPastLoc(_ loc:Int, modBy:Int){
        for i in 0..<data.count  {
            if data[i].loc >= loc {
                data[i].loc += modBy
            }
        }
    }
    
    func reindexedSubrange(_ range:CountableRange<Int>)->IAAttachmentArray{
        var results = IAAttachmentArray()
        for item in self.data {
            if item.loc >= range.lowerBound && item.loc < range.upperBound {
                results.data.append(LocAttach(loc:(item.loc - range.lowerBound), attach:item.attach))
            }
        }
        return results
    }
    
    ///Inserts the attachment or empty space (if nil) at a given index, increments locs past insert position by 1
    mutating func insertAttachment(_ attachment:IATextAttachment?, atLoc:Int){
        guard let attachment = attachment else {modifyIndecesAtOrPastLoc(atLoc, modBy: 1); return}
        let newItem = LocAttach(loc:atLoc, attach:attachment)
        if data.count > 0 {
            modifyIndecesAtOrPastLoc(atLoc, modBy: 1)
            for (i,item) in self.data.enumerated() {
                if item.loc > atLoc {
                    self.data.insert(newItem, at: i)
                    return
                }
            }
            self.data.insert(newItem, at: 0)
        } else {
            data.append(newItem)
        }
        
    }
    
    mutating func removeSubrange(_ range:CountableRange<Int>){
        var shouldRepeat = false
        repeat {
            shouldRepeat = false
            for (i,item) in self.data.enumerated() {
                if item.loc >= range.lowerBound && item.loc < range.upperBound {
                    self.data.remove(at: i)
                    shouldRepeat = true
                    break
                }
            }
        } while shouldRepeat
        modifyIndecesAtOrPastLoc(range.lowerBound, modBy: -range.count)
    }
    
    mutating func replaceRange(_ replacement:IAAttachmentArray, ofLength:Int ,replacedRange: CountableRange<Int>){
        removeSubrange(replacedRange)
        modifyIndecesAtOrPastLoc(replacedRange.lowerBound, modBy: ofLength)
        for item in replacement.data {
            self[item.loc + replacedRange.lowerBound] = item.attach
        }
        #if DEBUG
        guard validate() else {fatalError("IAAttachmentArray.validate failed")}
        #endif
    }
    
    mutating func insertAttachments(_ attachArray:IAAttachmentArray, ofLength:Int ,atIndex:Int){
        modifyIndecesAtOrPastLoc(atIndex, modBy: ofLength)
        for item in attachArray.data {
            self[item.loc + atIndex] = item.attach
        }
        #if DEBUG
        guard validate() else {fatalError("IAAttachmentArray.validate failed")}
        #endif
    }
    
    
    func validate()->Bool{
        guard self.data.count > 0 else {return true}
        guard self.data[0].loc >= 0 else {print("validateError: first loc == \(self.data[0].loc)");return false}
        let sortedData = self.data.sorted{$0.loc < $1.loc}
        for i in 0..<self.data.count {
            guard self.data[i].loc == sortedData[i].loc && self.data[i].attach == sortedData[i].attach else {return false}
        }
        return true
    }
    
    public var description:String {
        var descript = "IAAttachmentArray: "
        guard self.data.count > 0 else {return descript + "<empty>"}
        descript += "["
        for item in self.data {
            descript += "<loc:\(item.loc), \(item.attach)>, "
        }
        let loc = descript.index(before: descript.index(before: descript.endIndex))
        descript.removeSubrange(loc..<descript.endIndex)
        return descript + "]"
    }
    
    func deepCopy()->IAAttachmentArray{
        let newData:[LocAttach] = self.data.map({return LocAttach($0.loc, $0.attach.copy() as! IATextAttachment)})
        return IAAttachmentArray(data: newData)
    }
    
    func rangeIsEmpty(_ range:CountableRange<Int>)->Bool{
        for (loc,_) in data {
            if loc < range.lowerBound {
                continue
            } else if loc < range.upperBound {
                return false
            } else {
                return true
            }
        }
        return true
    }
    ///Returns all location-attachment tupples with locations contained in the provided range
    func attachmentsInRange(_ range:CountableRange<Int>)->[LocAttach]{
        var results:[LocAttach] = []
        for locAttach in data {
            if locAttach.loc < range.lowerBound {
                continue
            } else if locAttach.loc < range.upperBound {
                results.append(locAttach)
            } else {
                break
            }
        }
        return results
    }
    
    
    public func attachment(withLocalID localID:String)->LocAttach?{
        guard let index = data.index(where: {$0.attach.localID == localID}) else {return nil}
        return data[index]
    }
}
