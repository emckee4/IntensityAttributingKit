//
//  IAAttachmentArray.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 1/29/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import Foundation


public struct IAAttachmentArray:CustomStringConvertible, SequenceType {
    public typealias LocAttach = (loc:Int,attach:IATextAttachment)
    var data:[LocAttach] = []
    
    var lastLoc:Int? {return data.last?.loc}
    var count:Int {return data.count}
    
    init!(data:[LocAttach]){
        guard !data.isEmpty else {return}
        self.data = data.sort({$0.loc < $1.loc})
        for i in 0..<self.data.count - 1 {
            guard data[i].loc != data[i + 1].loc else {return nil}
        }
    }
    
    init(){}
    
    public typealias Generator = Array<LocAttach>.Generator
    
    public func generate() -> Generator {
        return data.generate()
    }
    
    private func dataIndexForLoc(loc:Int)->Int?{
        for (i, item) in data.enumerate() {
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
                        data.insert(LocAttach(loc:position, attach:attach), atIndex: i)
                        return
                    }
                }
                data.append(LocAttach(loc:position, attach:attach))
            } else {
                if let di = dataIndexForLoc(position) {
                    data.removeAtIndex(di)
                }
            }
        }
    }
    
    
    mutating func modifyIndecesAtOrPastLoc(loc:Int, modBy:Int){
        for i in 0..<data.count  {
            if data[i].loc >= loc {
                data[i].loc += modBy
            }
        }
    }
    
    func reindexedSubrange(range:Range<Int>)->IAAttachmentArray{
        var results = IAAttachmentArray()
        for item in self.data {
            if item.loc >= range.startIndex && item.loc < range.endIndex {
                results.data.append(LocAttach(loc:(item.loc - range.startIndex), attach:item.attach))
            }
        }
        return results
    }
    
    ///Inserts the attachment or empty space (if nil) at a given index, increments locs past insert position by 1
    mutating func insertAttachment(attachment:IATextAttachment?, atLoc:Int){
        guard let attachment = attachment else {modifyIndecesAtOrPastLoc(atLoc, modBy: 1); return}
        let newItem = LocAttach(loc:atLoc, attach:attachment)
        if data.count > 0 {
            modifyIndecesAtOrPastLoc(atLoc, modBy: 1)
            for (i,item) in self.data.enumerate() {
                if item.loc > atLoc {
                    self.data.insert(newItem, atIndex: i)
                    return
                }
            }
            self.data.insert(newItem, atIndex: 0)
        } else {
            data.append(newItem)
        }
        
    }
    
    mutating func removeSubrange(range:Range<Int>){
        var shouldRepeat = false
        repeat {
            shouldRepeat = false
            for (i,item) in self.data.enumerate() {
                if item.loc >= range.startIndex && item.loc < range.endIndex {
                    self.data.removeAtIndex(i)
                    shouldRepeat = true
                    break
                }
            }
        } while shouldRepeat
        modifyIndecesAtOrPastLoc(range.startIndex, modBy: -range.count)
    }
    
    mutating func replaceRange(replacement:IAAttachmentArray, ofLength:Int ,replacedRange: Range<Int>){
        removeSubrange(replacedRange)
        modifyIndecesAtOrPastLoc(replacedRange.startIndex, modBy: ofLength)
        for item in replacement.data {
            self[item.loc + replacedRange.startIndex] = item.attach
        }
        guard validate() else {fatalError("IAAttachmentArray.validate failed")}
    }
    
    mutating func insertAttachments(attachArray:IAAttachmentArray, ofLength:Int ,atIndex:Int){
        modifyIndecesAtOrPastLoc(atIndex, modBy: ofLength)
        for item in attachArray.data {
            self[item.loc + atIndex] = item.attach
        }
        guard validate() else {fatalError("IAAttachmentArray.validate failed")}
    }
    
    
    func validate()->Bool{
        guard self.data.count > 0 else {return true}
        guard self.data[0].loc >= 0 else {print("validateError: first loc == \(self.data[0].loc)");return false}
        let sortedData = self.data.sort{$0.loc < $1.loc}
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
        descript.removeRange(descript.endIndex.predecessor().predecessor()..<descript.endIndex)
        return descript + "]"
    }
    
    func deepCopy()->IAAttachmentArray{
        let newData:[LocAttach] = self.data.map({return LocAttach($0.loc, $0.attach.copy() as! IATextAttachment)})
        return IAAttachmentArray(data: newData)
    }
    
    func rangeIsEmpty(range:Range<Int>)->Bool{
        for (loc,_) in data {
            if loc < range.startIndex {
                continue
            } else if loc < range.endIndex {
                return false
            } else {
                return true
            }
        }
        return true
    }
    ///Returns all location-attachment tupples with locations contained in the provided range
    func attachmentsInRange(range:Range<Int>)->[LocAttach]{
        var results:[LocAttach] = []
        for locAttach in data {
            if locAttach.loc < range.startIndex {
                continue
            } else if locAttach.loc < range.endIndex {
                results.append(locAttach)
            } else {
                break
            }
        }
        return results
    }
    
//    public func setThumbSizes(thumbSize:ThumbSize){
//        for (_,attach) in self.data {
//            attach.thumbSize = thumbSize
//        }
//    }
}
