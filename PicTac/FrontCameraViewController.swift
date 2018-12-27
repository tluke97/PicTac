//
//  FrontCameraViewController.swift
//  CorkBoard
//
//  Created by Tanner Luke on 11/3/17.
//  Copyright © 2017 CorkBoard Co. All rights reserved.
//

import UIKit
import AVFoundation


class FrontCameraViewController: UIViewController , UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var switchFlash: UIButton!
    @IBOutlet weak var photo: UIImageView!
    var captureSession = AVCaptureSession()
    var backCamera: AVCaptureDevice?
    var frontCamera: AVCaptureDevice?
    var currentCamera: AVCaptureDevice?
    var photoOutput: AVCapturePhotoOutput?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    var image: UIImage?
    var newImage: UIImage?
    var finalImage: UIImage?
    var ratio: CGRect?
    var tryingThis: CGSize?
    var flashState = "off"
    
    enum CurrentFlashMode {
        case off
        case on
        case auto
    }
    var getFlash = CurrentFlashMode.off
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.isHidden = true
        loadCamera()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        dot.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(true)
        dot.isHidden = false
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
   
    @IBAction func library(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        photo.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        performSegue(withIdentifier: "thePickedImage", sender: nil)
    }
    
    func loadCamera() {
        setupCaptureSession()
        setupDevice()
        setupInputOutput()
        setupPreviewLayer()
        startRunningCaptureSession()
    }
    
    func getSettings(camera: AVCaptureDevice, flashMode: CurrentFlashMode) -> AVCapturePhotoSettings {
        let settings = AVCapturePhotoSettings()
        if camera.hasFlash {
            switch flashMode {
            case .auto: settings.flashMode = .auto
            case .on: settings.flashMode = .on
            default: settings.flashMode = .off
            }
        }
        return settings
    }
    
    @IBAction func pinchToZoom(_ sender: UIPinchGestureRecognizer) {
        guard let device = frontCamera else { return }
        if sender.state == .changed {
            let maxZoomFactor = device.activeFormat.videoMaxZoomFactor
            let pinchVelocityDividerFactor: CGFloat = 5.0
            do {
                try device.lockForConfiguration()
                defer { device.unlockForConfiguration() }
                let desiredZoomFactor = device.videoZoomFactor + atan2(sender.velocity, pinchVelocityDividerFactor)
                device.videoZoomFactor = max(1.0, min(desiredZoomFactor, maxZoomFactor))
            } catch {
                print(error)
            }
        }
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
    
    
    
    func setupCaptureSession() {
        captureSession.sessionPreset = AVCaptureSession.Preset.high
    }
    
    func setupDevice() {
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
    }
    
    func setupInputOutput() {
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentCamera!)
            captureSession.addInput(captureDeviceInput)
            photoOutput = AVCapturePhotoOutput()
            photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)
            captureSession.addOutput(photoOutput!)
        } catch {
            print(error)
        }
    }
    
    func setupPreviewLayer() {
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        cameraPreviewLayer?.frame = self.view.frame
        self.view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
    }
    
    func startRunningCaptureSession() {
        captureSession.startRunning()
    }
    
    @IBAction func takePicture(_ sender: Any) {
        //let settings = AVCapturePhotoSettings()
       var settings = getSettings(camera: currentCamera!, flashMode: CurrentFlashMode.off)
        
        if flashState == "on" {
            settings = getSettings(camera: currentCamera!, flashMode: CurrentFlashMode.on)
        } else {
            settings = getSettings(camera: currentCamera!, flashMode: CurrentFlashMode.off)
        }
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [
            kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
            kCVPixelBufferWidthKey as String: 512,
            kCVPixelBufferHeightKey as String: 512
        ]
        settings.previewPhotoFormat = previewFormat
        photoOutput?.capturePhoto(with: settings, delegate: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPicPreviewSegue" {
            let previewVC = segue.destination as! PreviewViewController
            let flippedImage = UIImage(cgImage: (image?.cgImage)!, scale: (image?.scale)! , orientation: .leftMirrored)
            previewVC.fromBackCamera = false
            previewVC.fromCrop = false
            previewVC.image = flippedImage
        }
        else if segue.identifier == "thePickedImage" {
            let previewVC = segue.destination as! PreviewViewController
            previewVC.fromBackCamera = false
            previewVC.fromCrop = false
            previewVC.image = photo.image
        }
    }
}
extension FrontCameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            image = UIImage(data: imageData)
            self.performSegue(withIdentifier: "toPicPreviewSegue", sender: nil)
        }
    }
}
