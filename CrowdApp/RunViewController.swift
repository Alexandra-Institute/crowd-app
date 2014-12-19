//
//  RunViewController.swift
//  CrowdApp
//
//  Created by Daniel Andersen on 25/11/14.
//
//

import UIKit
import CoreMotion
import AVFoundation

class RunViewController: UIViewController {

    @IBOutlet weak var doubleTapToReturnLabel: UILabel!
    
    var motionManager: CMMotionManager!
    
    var mode: Int! = 0
    
    var motionLastYaw: Double = 0.0
    
    var angle: Double = 0.0

    var colorLeft: UIColor! = UIColor.redColor()
    var colorRight: UIColor! = UIColor.blueColor()
    var colorUp: UIColor! = UIColor.greenColor()
    var colorDown: UIColor! = UIColor.yellowColor()

    var colorMovement: UIColor! = UIColor.whiteColor()

    var colorAudio1: UIColor! = UIColor.greenColor()
    var colorAudio2Red: CGFloat = 1.0
    var colorAudio2Green: CGFloat = 1.0
    var colorAudio2Blue: CGFloat = 0.0

    var threshold: Double!
    var flashEnabled: Bool!

    var audioMeter: AudioMeter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeMotionManager()
        self.initializeAudioMeter()
    }

    override func viewDidAppear(animated: Bool) {
        UIView.animateKeyframesWithDuration(1.0, delay: 2.0, options: UIViewKeyframeAnimationOptions.allZeros, animations: { () -> Void in
            self.doubleTapToReturnLabel.alpha = 0.0
            }, { (Bool cancelled) -> Void in
                self.doubleTapToReturnLabel.hidden = true
        })
    }
    
    override func viewWillDisappear(animated: Bool) {
        if (self.motionManager != nil) {
            self.motionManager.stopAccelerometerUpdates()
        }
        if (self.audioMeter != nil) {
            self.audioMeter.endAudioMetering()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initializeMotionManager() {
        if (self.mode > 1) {
            return
        }
        self.motionManager = CMMotionManager()
        if (self.motionManager.accelerometerAvailable) {
            self.motionManager.accelerometerUpdateInterval = 0.02
            self.motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: { (accelerometerData: CMAccelerometerData!, error: NSError!) -> Void in
                self.updateVisualization(accelerometerData)
            })
        }
    }

    func initializeAudioMeter() {
        if (self.mode < 2) {
            return
        }
        self.audioMeter = AudioMeter(samplePeriod: 0.1)
        self.audioMeter.beginAudioMeteringWithCallback { (value: Double) -> Void in
            self.updateVisualization(value)
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

    func updateVisualization(value: Double!) {
        switch (self.mode) {
        case 2:
            updateVisualizationMode3(value)
            break
        case 3:
            updateVisualizationMode4(value)
            break
        default:
            break
        }
    }
    
    func updateVisualizationMode1(accelerometerData: CMAccelerometerData!) {
        if (abs(accelerometerData.acceleration.z) > 0.4 && abs(accelerometerData.acceleration.z) <= 0.9) {
            return;
        }
        if (abs(accelerometerData.acceleration.z) > 0.9) {
            self.view.backgroundColor = UIColor.blackColor()
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
            self.turnFlashOn()
            var timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target:self, selector:Selector("turnFlashOff"), userInfo:nil, repeats:false)

            self.view.backgroundColor = self.colorMovement
            UIView.animateKeyframesWithDuration(0.3, delay:0.0, options:UIViewKeyframeAnimationOptions.allZeros, animations: { () -> Void in
                self.view.backgroundColor = UIColor.blackColor()
            }, completion: nil)
        }
    }

    func updateVisualizationMode3(value: Double!) {
        var force = self.logarithmicThresholded(value)
        if (force > 0.5) {
            self.turnFlashOn()
            var timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target:self, selector:Selector("turnFlashOff"), userInfo:nil, repeats:false)
            
            self.view.backgroundColor = self.colorAudio1
            UIView.animateKeyframesWithDuration(0.3, delay:0.0, options:UIViewKeyframeAnimationOptions.allZeros, animations: { () -> Void in
                self.view.backgroundColor = UIColor.blackColor()
                }, completion: nil)
        }
    }

    func updateVisualizationMode4(value: Double!) {
        var force = self.logarithmicThresholded(value)
        self.view.backgroundColor = UIColor(red: self.colorAudio2Red, green: self.colorAudio2Green, blue: self.colorAudio2Blue, alpha: CGFloat(force))
    }

    func logarithmicThresholded(value: Double!) -> Double! {
        var l = log10(value) // [-inf, 0]
        l = (l + 1.0 + (1.0 - self.threshold)) // [-inf, 1]
        return max(0.0, min(1.0, l))
    }
    
    func turnFlashOn() {
        self.toggleTorc(true)
    }
    
    func turnFlashOff() {
        self.toggleTorc(false)
    }

    func toggleTorc(toggle: Bool!) {
        if (!self.flashEnabled.boolValue) {
            return
        }
        var captureDeviceClass: AnyClass! = NSClassFromString("AVCaptureDevice");
        if (captureDeviceClass != nil) {
            var device: AVCaptureDevice! = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo);
            if (device.hasTorch && device.hasFlash){
                
                device.lockForConfiguration(nil);
                if (toggle.boolValue) {
                    device.torchMode = AVCaptureTorchMode.On
                    device.flashMode = AVCaptureFlashMode.On
                } else {
                    device.torchMode = AVCaptureTorchMode.Off
                    device.flashMode = AVCaptureFlashMode.Off
                }
                device.unlockForConfiguration()
            }
        }
    }

    @IBAction func doubleTapped(sender: UITapGestureRecognizer) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}
