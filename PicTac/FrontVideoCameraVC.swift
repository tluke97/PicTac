//
//  FrontVideoCameraVC.swift
//  CorkBoard
//
//  Created by Tanner Luke on 1/10/18.
//  Copyright © 2018 CorkBoard Co. All rights reserved.
//

import UIKit
import AVFoundation

var oldBrightness: CGFloat?

class FrontVideoCameraVC: UIViewController, AVCaptureFileOutputRecordingDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var thisBlows: UIView!
    @IBOutlet weak var switchFlash: UIButton!
    
    @IBOutlet weak var recordView: UIView!
    @IBOutlet weak var camPreview: UIView!
    @IBOutlet weak var record: UIButton!
    let shapeLayer = CAShapeLayer()
    let maxTime = CMTime(seconds: 10, preferredTimescale: CMTimeScale.max)
    var backCamera: AVCaptureDevice?
    var frontCamera: AVCaptureDevice?
    var currentCamera: AVCaptureDevice?
    let captureSession = AVCaptureSession()
    let movieOutput = AVCaptureMovieFileOutput()
    var previewLayer: AVCaptureVideoPreviewLayer!
    var activeInput: AVCaptureDeviceInput!
    var outputURL: URL!
    
    let flashView = UIView()
    let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
    var flashState = "off"
    
    enum CurrentFlashMode {
        case off
        case on
        case auto
    }
    
    var getFlash = CurrentFlashMode.off
    
    override func viewDidLoad() {
        super.viewDidLoad()
        flashView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        flashView.backgroundColor = .white
        flashView.alpha = 0.8
        thisBlows.isHidden = true
        camPreview.addSubview(flashView)
        self.view.isUserInteractionEnabled = true
        self.recordView.isUserInteractionEnabled = true
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action:#selector(pinchRecognized(pinch:)))
        pinchGesture.delegate = self
        self.view.addGestureRecognizer(pinchGesture)
        let center = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height - 65)
        let circularPath = UIBezierPath(arcCenter: center, radius: 27.5, startAngle: -CGFloat.pi / 2, endAngle: CGFloat.pi * 2, clockwise: true)
        shapeLayer.path = circularPath.cgPath
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.lineWidth = 5
        shapeLayer.strokeEnd = 0
        //record.frame = CGRect(x: self.view.frame.size.width/2 - 30, y: self.view.frame.size.height - 90 , width: 60, height: 60)
        view.layer.addSublayer(shapeLayer)
        
        shapeLayer.fillColor = nil
        if setupSession() {
            setupPreview()
            startSession()
        }
        
        basicAnimation.toValue = 1
        basicAnimation.duration = 11.5
        camPreview.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        thisBlows.isHidden = true
        if oldBrightness != nil {
            UIScreen.main.brightness = oldBrightness!
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func setupPreview() {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        previewLayer?.frame = self.view.frame
        self.view.layer.insertSublayer(previewLayer!, at: 0)
    }
    
    @IBAction func recordButton(_ sender: Any) {
        startCapture()
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0, execute: {
            if self.movieOutput.isRecording == true && self.movieOutput.recordedDuration >= self.maxTime {
                self.stopRecording()
            }
        })
    }
    
    @IBAction func switchFlashButton(_ sender: Any) {
        if flashState == "off" {
            flashState = "on"
            getFlash = .on
            let flashOnImage = UIImage(named: "FlashOn.png")
            switchFlash.setBackgroundImage(flashOnImage, for: UIControlState.normal)
        } else {
            let flashOffImage = UIImage(named: "FlashOff.png")
            switchFlash.setBackgroundImage(flashOffImage, for: UIControlState.normal)
            flashState = "off"
            getFlash = .off
        }
    }
    
    
    
    func setupSession() -> Bool {
        captureSession.sessionPreset = AVCaptureSession.Preset.high
        _ = AVCaptureDevice.default(for: .video) //was let camera =
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        let devices = deviceDiscoverySession.devices
        for device in devices  {
            if device.position == AVCaptureDevice.Position.back {
                backCamera = device
            } else if device.position == AVCaptureDevice.Position.front  {
                frontCamera = device
            }
        }
        currentCamera = frontCamera
        do {
            let input = try AVCaptureDeviceInput(device: currentCamera!)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
                activeInput = input
            }
        } catch {
            print("Error setting device video input: \(error)")
            return false
        }
        let microphone = AVCaptureDevice.default(for: .audio)
        do {
            let micInput = try AVCaptureDeviceInput(device: microphone!)
            if captureSession.canAddInput(micInput) {
                captureSession.addInput(micInput)
            }
        } catch {
            print("Error setting device audio input: \(error)")
            return false
        }
        if captureSession.canAddOutput(movieOutput) {
            captureSession.addOutput(movieOutput)
        }
        return true
    }
    func setupCaptureMode(_ mode: Int) {
    }
    
    func startSession() {
        if !captureSession.isRunning {
            videoQueue().async {
                self.captureSession.startRunning()
            }
        }
    }
    
    func stopSession() {
        if captureSession.isRunning {
            videoQueue().async {
                self.captureSession.stopRunning()
            }
        }
    }
    
    func videoQueue() -> DispatchQueue {
        return DispatchQueue.main
    }
    
    func currentVideoOrientation() -> AVCaptureVideoOrientation {
        var orientation: AVCaptureVideoOrientation
        switch UIDevice.current.orientation {
        case .portrait:
            orientation = AVCaptureVideoOrientation.portrait
        case .landscapeRight:
            orientation = AVCaptureVideoOrientation.landscapeLeft
        case .portraitUpsideDown:
            orientation = AVCaptureVideoOrientation.portraitUpsideDown
        default:
            orientation = AVCaptureVideoOrientation.landscapeRight
        }
        return orientation
    }
    
    func startCapture() {
        startRecording()
    }
    
    func tempURL() -> URL? {
        let directory = NSTemporaryDirectory() as NSString
        if directory != "" {
            let path = directory.appendingPathComponent(NSUUID().uuidString + ".mp4")
            return URL(fileURLWithPath: path)
        }
        return nil
    }
    
    func startRecording() {
        if movieOutput.isRecording == false {
            
            
            if flashState == "on" {
                oldBrightness = UIScreen.main.brightness
                thisBlows.isHidden = false
                UIScreen.main.brightness = 1.0
            }
            
            
            let connection = movieOutput.connection(with: AVMediaType.video)
            connection?.isVideoMirrored = true
            if (connection?.isVideoOrientationSupported)! {
                connection?.videoOrientation = currentVideoOrientation()
            }
            if (connection?.isVideoStabilizationSupported)! {
                connection?.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
            }
            let device = activeInput.device
            if (device.isSmoothAutoFocusSupported) {
                do {
                    try device.lockForConfiguration()
                    device.isSmoothAutoFocusEnabled = false
                    
                    device.activeVideoMinFrameDuration = CMTimeMake(1, 27)
                    device.activeVideoMaxFrameDuration = CMTimeMake(1, 27)
                    device.unlockForConfiguration()
                } catch {
                    print("Error setting configuration: \(error)")
                }
            }
            
            shapeLayer.add(basicAnimation, forKey: "string")
            outputURL = tempURL()
            movieOutput.startRecording(to: outputURL, recordingDelegate: self as AVCaptureFileOutputRecordingDelegate)
        } else {
            stopRecording()
        }
    }
    
    @objc func pinchRecognized(pinch: UIPinchGestureRecognizer) {
        guard let device = frontCamera else { return }
        if pinch.state == .changed {
            let maxZoomFactor = device.activeFormat.videoMaxZoomFactor
            let pinchVelocityDividerFactor: CGFloat = 5.0
            do {
                try device.lockForConfiguration()
                defer { device.unlockForConfiguration() }
                let desiredZoomFactor = device.videoZoomFactor + atan2(pinch.velocity, pinchVelocityDividerFactor)
                device.videoZoomFactor = max(1.0, min(desiredZoomFactor, maxZoomFactor))
            } catch {
                print(error)
            }
        }
    }
    
    func stopRecording() {
        if movieOutput.isRecording == true {
            movieOutput.stopRecording()
            //UIScreen.main.brightness = oldBrightness!
            //self.flashView.removeFromSuperview()
        }
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        if (error != nil) {
            print("Error recording movie: \(error!.localizedDescription)")
        } else {
            let videoRecorded = outputURL! as URL
            performSegue(withIdentifier: "showVideo", sender: videoRecorded)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showVideo" {
            let vc = segue.destination as! VideoPlayback
            vc.videoURL = sender as? URL
        }
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if (error != nil) {
            print("Error recording movie: \(error!.localizedDescription)")
        } else {
            let videoRecorded = outputURL! as URL
            performSegue(withIdentifier: "showVideo", sender: videoRecorded)
        }
    }
}
