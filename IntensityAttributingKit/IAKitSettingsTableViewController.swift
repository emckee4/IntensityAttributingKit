//
//  IAKitSettingsTableViewController.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 3/15/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit

///This holds the IAKit adjustment cells necessary for configuring intensity interpreters. It will typically be presented within the ModalContainerViewController when the gear icon is pressed on the IAAccessory.
class IAKitSettingsTableViewController: UITableViewController {

    var tiNameCells:[UITableViewCell]!
    var tiAdjustmentCells:[RawIntensityAdjustmentCellBase]!
    var rimNameCells:[UITableViewCell]!
    var rimAdjustmentCells:[RawIntensityAdjustmentCellBase]!
    
    var miscCells:[UITableViewCell]!
    
    var expandedTIAdjusterIndex:NSIndexPath?
    var expandedRIMAdjusterIndex:NSIndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //The content is limited and unchanging so this is slightly simpler since we don't have to worry about disconnecting and reconnecting cells with the persistance layer. Order/position will also be easier to see.
        setupNameCells()
        //init adjustment cells
        tiAdjustmentCells = [ForceTIAdjustmentCell(),DurationTIAdjustmentCell(),ImpactDurationTIAdjustmentCell()]
        rimAdjustmentCells = [LinearRIMAdjustmentCell(), LogAxRIMAdjustmentCell()]

        
        miscCells = [SpellCheckToggleCell()]
        
        tableView.estimatedRowHeight = 40.0
        tableView.rowHeight =  UITableViewAutomaticDimension
        self.tableView.allowsMultipleSelection = true
        
        //mark as highlighted/selected those cells that are current in the IAKitPreferences
        
        refreshSelections()
        tableView.separatorStyle = .None
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tiNameCells.count + rimNameCells.count + miscCells.count + 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if expandedTIAdjusterIndex?.section == section || expandedRIMAdjusterIndex?.section == section {
            return 2
        } else if section < 6{
            return 1
        } else {
            return 0
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //var cell:UITableViewCell!
        let section = indexPath.section
        let row = indexPath.row
        if row == 0 { // name cells
            if section < 3 {
                return tiNameCells[section]
            } else if section < 5{
                return rimNameCells[section - 3]
            } else {
                return miscCells[section - 5]
            }
        } else { //param adjustment cells
            if section < 3 {
                return tiAdjustmentCells[section]
            } else {
                return rimAdjustmentCells[section - 3]
            }
        }
    }

    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        tableView.beginUpdates()
        if indexPath.section == expandedTIAdjusterIndex?.section { //closing expanded ti cell
            tableView.deleteRowsAtIndexPaths([expandedTIAdjusterIndex!], withRowAnimation: .Top)
            expandedTIAdjusterIndex = nil
        } else if indexPath.section == expandedRIMAdjusterIndex?.section { //closing expanded rim cell
            tableView.deleteRowsAtIndexPaths([expandedRIMAdjusterIndex!], withRowAnimation: .Top)
            expandedRIMAdjusterIndex = nil
        } else if indexPath.section < 3 {   //opening/changing expanded ti cell
            if expandedTIAdjusterIndex != nil {
                tableView.deleteRowsAtIndexPaths([expandedTIAdjusterIndex!], withRowAnimation: .Top)
            }
            expandedTIAdjusterIndex = NSIndexPath(forRow: 1, inSection: indexPath.section)
            tableView.insertRowsAtIndexPaths([expandedTIAdjusterIndex!], withRowAnimation: .Top)
        } else if indexPath.section >= 3 {  //opening/changing expanded rim cell
            if expandedRIMAdjusterIndex != nil {
                tableView.deleteRowsAtIndexPaths([expandedRIMAdjusterIndex!], withRowAnimation: .Top)
            }
            expandedRIMAdjusterIndex = NSIndexPath(forRow: 1, inSection: indexPath.section)
            tableView.insertRowsAtIndexPaths([expandedRIMAdjusterIndex!], withRowAnimation: .Top)
            
        }
        tableView.endUpdates()
    }
    

    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        guard indexPath.row == 0 && indexPath.section < 5 else {return nil}
        guard let nameCell = tableView.cellForRowAtIndexPath(indexPath) else {return nil}
        guard nameCell.selected == false else {return nil}
        guard IAKitPreferences.forceTouchAvailable || !(nameCell.textLabel!.text! == "ForceTouch") else {return nil}
        //ensure only one cell per section is highlighted

        if indexPath.section < 3 {
            _ = [NSIndexPath(forRow: 0, inSection: 0),NSIndexPath(forRow: 0, inSection: 1),NSIndexPath(forRow: 0, inSection: 2)].map({tableView.deselectRowAtIndexPath($0, animated: true)})
        } else  { //indexPath.section < 5
            _ = [NSIndexPath(forRow: 0, inSection: 3),NSIndexPath(forRow: 0, inSection: 4)].map({tableView.deselectRowAtIndexPath($0, animated: true)})
        }
        
        return indexPath
    }
    
    ///we don't want to allow the user to deselect rows
    override func tableView(tableView: UITableView, willDeselectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        return nil
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 0: IAKitPreferences.touchInterpreter = IATouchInterpreter.Force
            
        case 1: IAKitPreferences.touchInterpreter = IATouchInterpreter.Duration
            
        case 2: IAKitPreferences.touchInterpreter = IATouchInterpreter.ImpactDuration
            
        case 3: IAKitPreferences.rawIntensityMapper = .Linear
            
        case 4: IAKitPreferences.rawIntensityMapper = .LogAx


        default: return
        }
        if indexPath.section < 3 && expandedTIAdjusterIndex != nil && indexPath.section != expandedTIAdjusterIndex?.section {
            tableView.beginUpdates()
            tableView.deleteRowsAtIndexPaths([expandedTIAdjusterIndex!], withRowAnimation: .Top)
            expandedTIAdjusterIndex = nil
            tableView.endUpdates()
        } else if indexPath.section >= 3 && indexPath.section < 5 && expandedRIMAdjusterIndex != nil && indexPath.section != expandedRIMAdjusterIndex?.section {
            tableView.beginUpdates()
            tableView.deleteRowsAtIndexPaths([expandedRIMAdjusterIndex!], withRowAnimation: .Top)
            expandedRIMAdjusterIndex = nil
            tableView.endUpdates()
        }
        
    }
    
    ///Updates cell selections with defaults from IAKitOPtions
    func refreshSelections(){
        var selectedTIIndex:NSIndexPath!
        var selectedRIMIndex:NSIndexPath!
        switch IAKitPreferences.touchInterpreter {
        case .Force: selectedTIIndex = NSIndexPath(forRow: 0, inSection: 0)
        case .Duration: selectedTIIndex = NSIndexPath(forRow: 0, inSection: 1)
        case .ImpactDuration: selectedTIIndex = NSIndexPath(forRow: 0, inSection: 2)
        }
        
        switch IAKitPreferences.rawIntensityMapper {
        case .Linear: selectedRIMIndex = NSIndexPath(forRow: 0, inSection: 3)
        case .LogAx: selectedRIMIndex = NSIndexPath(forRow: 0, inSection: 4)
        }
        
        if let previouslySelected = tableView.indexPathsForSelectedRows {
            for previousIP in previouslySelected {
                if previousIP != selectedRIMIndex && previousIP != selectedTIIndex {
                    tableView.deselectRowAtIndexPath(previousIP, animated: false)
                }
            }
        }
        tableView.selectRowAtIndexPath(selectedTIIndex, animated: false, scrollPosition: .None)
        tableView.selectRowAtIndexPath(selectedRIMIndex, animated: false, scrollPosition: UITableViewScrollPosition.None)
        
    }
    

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Touch Interpreters"
        case 3: return "Raw Intensity Mapping"
        case 5: return "Other Options"
        default: return nil
        }
    }
    
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0: return 28.0
        case 3: return 28.0
        case 5: return 28.0
        default: return 3.0
        }
    }
    


    
    func setupNameCells(){
        tiNameCells = [UITableViewCell(style: .Default, reuseIdentifier: "nameCell"),UITableViewCell(style: .Default, reuseIdentifier: "nameCell"),UITableViewCell(style: .Default, reuseIdentifier: "nameCell")]
        tiNameCells[0].textLabel?.text = "ForceTouch"
        tiNameCells[1].textLabel?.text = "Duration"
        tiNameCells[2].textLabel?.text = "Impact-Duration"
        _ = tiNameCells.map({$0.accessoryType = .DetailButton; $0.textLabel?.font = UIFont.systemFontOfSize(20.0); $0.selectionStyle = UITableViewCellSelectionStyle.Blue})
        
        rimNameCells = [UITableViewCell(style: .Default, reuseIdentifier: "nameCell"),UITableViewCell(style: .Default, reuseIdentifier: "nameCell")]
        rimNameCells[0].textLabel?.text = "Linear"
        rimNameCells[1].textLabel?.text = "LogAx"
        _ = rimNameCells.map({$0.accessoryType = .DetailButton; $0.textLabel?.font = UIFont.systemFontOfSize(20.0); $0.selectionStyle = UITableViewCellSelectionStyle.Blue})
    }

}
