//
//  RawIntensity.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 11/1/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//

import Foundation


public class RawIntensity{
   
    public static var rawIntensityMapping:RawIntensityMapping = IAKitOptions.rawIntensityMapper {
        didSet{intensityMappingFunction = rawIntensityMapping.function}
    }
    private(set)static var intensityMappingFunction:RawIntensityMappingFunction = IAKitOptions.rawIntensityMapper.function
    
    
    static var touchInterpreter:IATouchInterpreter = IAKitOptions.touchInterpreter {
        didSet{
            _ = RawIntensity.rawIntensityInstances.map({($0 as? RawIntensity)?.currentInterpreter = touchInterpreter.newInstance})}
    }
    private var currentInterpreter:IATouchInterpretingProtocol = RawIntensity.touchInterpreter.newInstance
//    {
//        didSet{print("updated currentInterpreter")}
//    }
    
    func updateIntensity(withTouch touch:UITouch){
        currentInterpreter.updateIntensityYieldingRawResult(withTouch: touch)
    }
    
    func endInteraction(withTouch touch:UITouch?)->Int{
        let raw = currentInterpreter.endInteractionYieldingRawResult(withTouch: touch)
        return RawIntensity.intensityMappingFunction(raw:raw)
    }
    
    func cancelInteraction(){
        currentInterpreter.cancelInteraction()
    }
    
    var currentIntensity:Int! {
        guard let raw = currentInterpreter.currentRawValue else {return nil}
        return RawIntensity.intensityMappingFunction(raw: raw)
    }
    
    
    
    
    init(){
        RawIntensity.rawIntensityInstances.addObject(self)
    }
    
    deinit{
        RawIntensity.rawIntensityInstances.removeObject(self)
    }
    
    
    private static var rawIntensityInstances:NSHashTable = NSHashTable(options: NSPointerFunctionsOptions.WeakMemory, capacity: 40)
}






/* Notes:

Process: rawIntensity contained by control is reset on touches began with:
rawIntensity = RawIntensity(withValue: touch.force,maximumPossibleForce: touch.maximumPossibleForce)
    or
rawIntensity.reset()

This restarts the timer and sets the force array to [0]

This should be replaced by a touchinside method and a reset method/ or 
update/begin
end -> with result
cancel

RawIntensity handles touch, packages everything




//intensitymapping is limited to the mapping curve and can be handled more or less as is, with some adjustments to the interface for saving/restoring-  and with function parameters being (raw:Int)->Int





*/






























