//
//  ViewController.swift
//  CrowdApp
//
//  Created by Daniel Andersen on 24/11/14.
//
//

import UIKit

class ViewController: UITableViewController, UITableViewDelegate {
    
    @IBOutlet weak var modeDescriptionTextView: UITextView!
    @IBOutlet weak var thresholdSlider: UISlider!
    
    var selectedMode: Int = 0
    var selectedFlash: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.tableHeaderView = UIView(frame: CGRectMake(0, 0, self.view.frame.size.width, 20));
        
        self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0)

        self.modeDescriptionTextView.text = self.explanationForMode(self.selectedMode)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.section == 0) {
            self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: selectedMode, inSection: 0))?.accessoryType = UITableViewCellAccessoryType.None

            self.selectedMode = indexPath.row
            
            self.tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.Checkmark

            self.modeDescriptionTextView.text = self.explanationForMode(self.selectedMode)
        }
        
        if (indexPath.section == 3) {
            self.selectedFlash = !self.selectedFlash
            self.tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = self.selectedFlash ? UITableViewCellAccessoryType.Checkmark : UITableViewCellAccessoryType.None
        }

        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func explanationForMode(mode: Int) -> String {
        switch (mode) {
        case 0:
            return "The phone's orientation will switch between 4 screen colors"
        case 1:
            return "Movement above the threshold will activate a screen color and flash the camera LED (if selected)"
        case 2:
            return "A sound level above the threshold will activate a color and flash the camera LED (if selected)"
        case 3:
            return "The sound level will produce a constant screen color animation - the phone's orientation will switch the camera LED on or off (if selected)"
        default:
            return "";
        }
    }
    
    @IBAction func runButtonPressed(sender: UIButton) {
        self.performSegueWithIdentifier("menuToRunSegue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier! == "menuToRunSegue") {
            (segue.destinationViewController as RunViewController).mode = self.selectedMode
            (segue.destinationViewController as RunViewController).threshold = Double(self.thresholdSlider.value)
            (segue.destinationViewController as RunViewController).flashEnabled = self.selectedFlash
        }
    }
}
