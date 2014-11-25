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

    var motionManager: CMMotionManager!
    
    var mode: Int! = 0
    
    var motionLastYaw: Double = 0.0
    
    var angle: Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeMotionManager()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initializeMotionManager() {
        self.motionManager = CMMotionManager()
        if (self.motionManager.deviceMotionAvailable) {
            self.motionManager.deviceMotionUpdateInterval = 0.02
            self.motionManager.startDeviceMotionUpdatesUsingReferenceFrame(CMAttitudeReferenceFrameXArbitraryZVertical, toQueue: NSOperationQueue.mainQueue(), withHandler: { (deviceMotion: CMDeviceMotion!, error: NSError!) -> Void in
                self.updateVisualization(deviceMotion)
            })
        }

        if (self.motionManager.accelerometerAvailable) {
            self.motionManager.accelerometerUpdateInterval = 0.02
            self.motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: { (accelerometerData: CMAccelerometerData!, error: NSError!) -> Void in
                self.updateVisualization(accelerometerData)
            })
        }
    }
    
    func updateVisualization(deviceMotion: CMDeviceMotion!) {
        switch (self.mode) {
        case 0:
            updateVisualizationMode1(deviceMotion)
            break
        default:
            break
        }
    }

    func updateVisualization(accelerometerData: CMAccelerometerData!) {
        switch (self.mode) {
        case 0:
            updateVisualizationMode1(accelerometerData)
            break
        default:
            break
        }
    }

    func updateVisualizationMode1(deviceMotion: CMDeviceMotion!) {
        var color: Double = angle + (2.0*M_PI)
        if (color > 2.0 * M_PI) { color -= M_PI * 2.0 }
        color /= (M_PI * 2.0)
        
        self.view.backgroundColor = UIColor(white: CGFloat(color), alpha: 1.0)
    }
    
    func updateVisualizationMode1(accelerometerData: CMAccelerometerData!) {
        self.angle = atan2(accelerometerData.acceleration.x, accelerometerData.acceleration.y)
    }

    func yawFromDeviceMotion(deviceMotion: CMDeviceMotion!) -> Double {
        var quaternion: CMQuaternion! = self.motionManager.deviceMotion.attitude.quaternion
        
        var yaw: Double = asin(2 * (quaternion.x * quaternion.z - quaternion.w * quaternion.y))

        if (angle < 0.0) {
            yaw += M_PI
        }
        
        if (self.motionLastYaw == 0) {
            self.motionLastYaw = yaw
        }
        
        // kalman filtering
        var q: Double = 0.1   // process noise
        var r: Double = 0.1   // sensor noise
        var p: Double = 0.1   // estimated error
        var k: Double = 0.5   // kalman filter gain
        
        var x: Double = self.motionLastYaw
        p = p + q
        k = p / (p + r)
        x = x + k * (yaw - x)
        p = (1 - k) * p
        self.motionLastYaw = x
        
        return x
    }
}
