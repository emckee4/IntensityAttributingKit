//
//  RawIntensity.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 11/1/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//

import Foundation

/**The RawIntensity is the front end of the intensity determining system of the IAKit. RawIntensity passes in touch events to an IATouchInterpreter and converts this data to a raw intensity value. This value is then passed through a RawIntensityMapping function which rescales the raw intensity according to its configurable parameters. The touch interpreter, RIM function, and their parameters are stored in the IAKitPreferences and they're most easily configured via
IAKitSettingsTableViewController which is presented by pressing the gear in the IAAccessory. */
open class RawIntensity{
   
    open static var rawIntensityMapping:RawIntensityMapping = IAKitPreferences.rawIntensityMapper {
        didSet{intensityMappingFunction = rawIntensityMapping.makeRIMFunction}
    }
    ///Only one RIM function needs to be generated for each set of parameters. This function can then be used by all RawIntensity objects.
    fileprivate(set)static var intensityMappingFunction:RawIntensityMappingFunction = IAKitPreferences.rawIntensityMapper.makeRIMFunction
    
    
    static var touchInterpreter:IATouchInterpreter = IAKitPreferences.touchInterpreter {
        //if we change the touchInterpreter type then we need to provide instances of the new touchInterpreter to all instances of RawIntensity
        didSet{
            if oldValue != touchInterpreter { oldValue.deactivate();}
            NotificationCenter.default.post(Notification(name:RawIntensity.touchInterpreterChangedName, object: nil))
            //_ = RawIntensity.rawIntensityInstances.map({($0 as? RawIntensity)?.currentInterpreter = touchInterpreter.newInstance})
        }
    }
    fileprivate var currentInterpreter:IATouchInterpretingProtocol = RawIntensity.touchInterpreter.newInstance()
    
    @objc fileprivate func updateCurrentInterpreter() {
        self.currentInterpreter = RawIntensity.touchInterpreter.newInstance()
    }
    
    ///Called by touchesBegan/Changed/Ended functions in controls utilizing RawIntensity.
    func updateIntensity(withTouch touch:UITouch){
        _ = currentInterpreter.updateIntensityYieldingRawResult(withTouch: touch)
    }
    
    ///Called by Ended function in controls utilizing RawIntensity.
    func endInteraction(withTouch touch:UITouch?)->Int{
        let raw = currentInterpreter.endInteractionYieldingRawResult(withTouch: touch)
        return RawIntensity.intensityMappingFunction(raw)
    }
    
    ///Called by touchesCancelled function in controls utilizing RawIntensity.
    func cancelInteraction(){
        currentInterpreter.cancelInteraction()
    }
    
    ///Most current value of intensity, 0-100
    var currentIntensity:Int! {
        guard let raw = currentInterpreter.currentRawValue else {return nil}
        return RawIntensity.intensityMappingFunction(raw)
    }
    
    static let touchInterpreterChangedName:NSNotification.Name = NSNotification.Name(rawValue: "touchInterpreterChanged")
    
    init(){
        //RawIntensity.rawIntensityInstances.add(self)
        NotificationCenter.default.addObserver(self, selector: #selector(updateCurrentInterpreter), name: RawIntensity.touchInterpreterChangedName, object: nil)
    }
    
    deinit{
        //RawIntensity.rawIntensityInstances.remove(self)
        NotificationCenter.default.removeObserver(self)
    }
    
    ///Storing all instances in a weak NSHashTable lets us perform actions on all existing instances of RawIntensity at once. This is mainly used for propagating changes to the RawIntensityMapping or touchInterpreter functions used by all RawIntensity classes.
    //fileprivate static var rawIntensityInstances:NSHashTable<RawIntensity> = NSHashTable(options: NSPointerFunctions.Options.weakMemory, capacity: 40)

    
}






























