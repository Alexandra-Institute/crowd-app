//
//  RunViewController.swift
//  CrowdApp
//
//  Created by Daniel Andersen on 25/11/14.
//
//

import UIKit
import CoreMotion

class RunViewController: UIViewController {

    @IBOutlet weak var doubleTapToReturnLabel: UILabel!
    
    var motionManager: CMMotionManager!
    
    var mode: Int! = 0
    
    var motionLastYaw: Double = 0.0
    
    var angle: Double = 0.0

    var colorLeft: UIColor! = UIColor.redColor()
    var colorRight: UIColor! = UIColor.redColor()
    var colorUp: UIColor! = UIColor.greenColor()
    var colorDown: UIColor! = UIColor.greenColor()
    var colorMovement: UIColor! = UIColor.whiteColor()

    var threshold: Double!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeMotionManager()
    }

    override func viewDidAppear(animated: Bool) {
        UIView.animateKeyframesWithDuration(1.0, delay: 5.0, options: UIViewKeyframeAnimationOptions.allZeros, animations: { () -> Void in
            self.doubleTapToReturnLabel.alpha = 0.0
            }, { (Bool cancelled) -> Void in
                self.doubleTapToReturnLabel.hidden = true
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initializeMotionManager() {
        self.motionManager = CMMotionManager()
        if (self.motionManager.accelerometerAvailable) {
            self.motionManager.accelerometerUpdateInterval = 0.02
            self.motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: { (accelerometerData: CMAccelerometerData!, error: NSError!) -> Void in
                self.updateVisualization(accelerometerData)
            })
        }
    }
    
    func updateVisualization(accelerometerData: CMAccelerometerData!) {
        switch (self.mode) {
        case 0:
            updateVisualizationMode1(accelerometerData)
            break
        case 1:
            updateVisualizationMode2(accelerometerData)
            break
        default:
            break
        }
    }

    func updateVisualizationMode1(accelerometerData: CMAccelerometerData!) {
        if (abs(accelerometerData.acceleration.z) > 0.95) {
            return
        }
        self.angle = atan2(accelerometerData.acceleration.x, accelerometerData.acceleration.y)
        if (self.angle < 0) {
            self.angle += M_PI * 2
        }

        var color: UIColor
        
        var buffer = M_PI / 16
        
        if (angle >= M_PI * 2 - M_PI_4 + buffer || angle < M_PI_2 - M_PI_4 - buffer) {
            self.view.backgroundColor = self.colorUp
        }
        if (angle >= M_PI_2 - M_PI_4 + buffer && angle < M_PI - M_PI_4 - buffer) {
            self.view.backgroundColor = self.colorLeft
        }
        if (angle >= M_PI - M_PI_4 + buffer && angle < M_PI + M_PI_2 - M_PI_4 - buffer) {
            self.view.backgroundColor = self.colorDown
        }
        if (angle >= M_PI + M_PI_2 - M_PI_4 + buffer && angle < M_PI * 2 - M_PI_4 - buffer) {
            self.view.backgroundColor = self.colorRight
        }
}

    func updateVisualizationMode2(accelerometerData: CMAccelerometerData!) {
        var force = accelerometerData.acceleration.x * accelerometerData.acceleration.x + accelerometerData.acceleration.y*accelerometerData.acceleration.y + accelerometerData.acceleration.z*accelerometerData.acceleration.z
        force = abs(1.0 - force)

        if (force > ((self.threshold * 50.0) + 3.0)) {
            self.view.backgroundColor = self.colorMovement
            UIView.animateKeyframesWithDuration(0.3, delay: 0.0, options: UIViewKeyframeAnimationOptions.allZeros, animations: { () -> Void in
                self.view.backgroundColor = UIColor.blackColor()
            }, completion: nil)
        }
    }

    @IBAction func doubleTapped(sender: UITapGestureRecognizer) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}
