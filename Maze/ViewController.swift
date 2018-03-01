//
//  ViewController.swift
//  Maze
//
//  Created by Zixiang Liu on 2/18/18.
//  Copyright © 2018 Zixiang Liu. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController, UINavigationControllerDelegate{
    
    @IBOutlet fileprivate var captureButton: UIButton!
    @IBOutlet fileprivate var capturePreviewView: UIView!
    @IBOutlet fileprivate var toggleFlashButton: UIButton!
    @IBOutlet fileprivate var toggleSaveButton: UIButton!
    
    var save: Bool!
    
    let cameraController = CameraController()
    
    var wholeImage: UIImage!
    var mazeImage: UIImage!
    var comment: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.save = false
        
        func configureCameraController() {
            cameraController.prepare {(error) in
                if let error = error {
                    print(error)
                }
                
                try? self.cameraController.displayPreview(on: self.capturePreviewView)
            }
        }
        
        func styleCaptureButton() {
            captureButton.layer.borderColor = UIColor.black.cgColor
            captureButton.layer.borderWidth = 2
            
            captureButton.layer.cornerRadius = min(captureButton.frame.width, captureButton.frame.height) / 2
        }
        
        styleCaptureButton()
        configureCameraController()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier=="PreviewContrl"){
            let destination = segue.destination as! PreviewController
            self.captureImage(destination: destination)
        }
    }
    
    func detectRect(image: CIImage) -> CIImage? {
        var resultImage: CIImage?
        let detector:CIDetector = CIDetector(ofType: CIDetectorTypeRectangle, context: nil, options: [CIDetectorAccuracy : CIDetectorAccuracyHigh])!
        // Get the detections
        let features = detector.features(in: image)
        print("Found \(features.count) Rects")
        for feature in features as! [CIRectangleFeature] {
            resultImage = self.cropRect(image: image, feature: feature)
            self.wholeImage = UIImage(ciImage: overlay(originalImage: image, feature: feature))
        }
        return resultImage
    }
    
    func overlay(originalImage image: CIImage, feature rect: CIRectangleFeature) -> CIImage{
        var overlay = CIImage(color: CIColor(red: 1.0, green: 0.55, blue: 0.0, alpha: 0.45))
        overlay = overlay.cropped(to: image.extent)
        overlay = overlay.applyingFilter("CIPerspectiveTransformWithExtent",
                                            parameters: [
                                                    "inputExtent": CIVector(cgRect: image.extent),
                                                    "inputTopLeft": CIVector(cgPoint: rect.topLeft),
                                                    "inputTopRight": CIVector(cgPoint: rect.topRight),
                                                    "inputBottomLeft": CIVector(cgPoint: rect.bottomLeft),
                                                    "inputBottomRight": CIVector(cgPoint: rect.bottomRight)
            ])
        return overlay.composited(over: image)
    }
    
    func cropRect(image originalImage: CIImage, feature rect:CIRectangleFeature) -> CIImage? {

        let perspectiveCorrection = CIFilter(name: "CIPerspectiveCorrection")!
        
        let docImage = originalImage
        
        perspectiveCorrection.setValue(CIVector(cgPoint:rect.topLeft),
                                       forKey: "inputTopLeft")
        perspectiveCorrection.setValue(CIVector(cgPoint:rect.topRight),
                                       forKey: "inputTopRight")
        perspectiveCorrection.setValue(CIVector(cgPoint:rect.bottomRight),
                                       forKey: "inputBottomRight")
        perspectiveCorrection.setValue(CIVector(cgPoint:rect.bottomLeft),
                                       forKey: "inputBottomLeft")
        perspectiveCorrection.setValue(docImage,
                                       forKey: kCIInputImageKey)
        
        let outputImage = perspectiveCorrection.outputImage
        
        return outputImage
    }
    
    @IBAction func toggleFlash(_ sender: UIButton) {
        if cameraController.flashMode == .on {
            cameraController.flashMode = .off
            toggleFlashButton.setImage(#imageLiteral(resourceName: "ic_flash_off"), for: .normal)
        }
            
        else {
            cameraController.flashMode = .on
            toggleFlashButton.setImage(#imageLiteral(resourceName: "ic_flash_on"), for: .normal)
        }
    }
    
    @IBAction func toggleSave(_ sender: UIButton) {
        if self.save == false {
            self.save = true
            toggleSaveButton.setImage(#imageLiteral(resourceName: "save"), for: .normal)
        }
            
        else {
            self.save = false
            toggleSaveButton.setImage(#imageLiteral(resourceName: "Nsave"), for: .normal)
        }
    }
    
    func captureImage(destination destin:PreviewController){
        cameraController.captureImage {(image, error) in
            guard let photo = image else {
                print(error ?? "Image capture error")
                return
            }
            if let found = self.detectRect(image: CIImage(image: photo)!){
                print("Found Rect")
                // self.wholeImage set in detectRect in this case
                self.mazeImage = UIImage(ciImage: found)
                self.comment = "Found Rect"
            }else{
                print("Didnt Found")
                self.wholeImage = photo
                self.mazeImage = #imageLiteral(resourceName: "huaji")
                self.comment = "Didn't Found"
            }
            
            if (self.save){
                try? PHPhotoLibrary.shared().performChangesAndWait {
                    PHAssetChangeRequest.creationRequestForAsset(from: self.mazeImage)
                }
            }

            destin.comment = self.comment
            destin.mazeImage = self.mazeImage
            destin.wholeImage = self.wholeImage
            destin.update()
        }
    }
    
}
