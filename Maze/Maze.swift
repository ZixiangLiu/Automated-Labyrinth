//
//  Maze.swift
//  Maze
//
//  Created by Zixiang Liu on 2/28/18.
//  Copyright © 2018 Zixiang Liu. All rights reserved.
//

import Foundation
import UIKit

class Maze{
    var mazeImage: UIImage!
    var wholeImage: UIImage!
    var greyImage: UIImage?
    var smallImage: UIImage!
    var comment: String!
    
    let w = 600
    let h = 600
    let bitmapInfo = CGBitmapInfo().rawValue
    let colorSpace = CGColorSpaceCreateDeviceGray()
    var matrix: Array<Array<Bool>>!
    
    func setValue(mazeImage maze: UIImage, wholeImage whole: UIImage, comment comm: String){
        self.mazeImage = maze
        self.wholeImage = whole
        self.comment = comm
    }
    
    func resizeCI(inputSize size:CGSize, inputImage iimage: UIImage) -> UIImage? {
        let scale = (Double)(size.width) / (Double)(iimage.size.width)
        let image = iimage.ciImage!
        
        let filter = CIFilter(name: "CILanczosScaleTransform")!
        filter.setValue(image, forKey: kCIInputImageKey)
        filter.setValue(NSNumber(value:scale), forKey: kCIInputScaleKey)
        filter.setValue(1.0, forKey:kCIInputAspectRatioKey)
        let outputImage = filter.value(forKey: kCIOutputImageKey) as! UIKit.CIImage
        
        let context = CIContext(options: [kCIContextUseSoftwareRenderer: false])
        let resizedImage = UIImage(cgImage: context.createCGImage(outputImage, from: outputImage.extent)!)
        return resizedImage
    }
    
    func resize(){
        let size = CGSize(width: w, height: h)
        self.smallImage = resizeCI(inputSize: size, inputImage: self.mazeImage)
    }
    
    // convert the maze image to grey scale and store the image
    // always run this or the greyimage is nil
    func convertToGrayScale(){
        let context = CGContext(data: nil, width: w, height: h, bitsPerComponent: 8, bytesPerRow: w, space: colorSpace, bitmapInfo: bitmapInfo)
        if let cont = context{
            cont.draw(self.smallImage.cgImage!, in: CGRect(x: 0, y: 0, width: w, height: h))
        }else{
            print("Nil context")
        }
        
        let mask = context!.makeImage()!
        self.greyImage = UIImage(cgImage: mask)
    }
    
    // use this method to get the matrix of the maze grey scale
    func generateMatrix() -> Array<Array<Bool>>? {
        if let grey = self.greyImage {
            return grey.cgGetMatrix()
        }else{
            self.convertToGrayScale()
            return self.generateMatrix()
        }
    }
    
    // Use this method to get the matrix image of the maze grey scale
    func generateMatrixImage() -> UIImage? {
        if let mat = self.generateMatrix(){
            let context = CGContext(data: nil, width: w, height: h, bitsPerComponent: 8, bytesPerRow: w, space: colorSpace, bitmapInfo: bitmapInfo)!
            
            if let pixelBuffer = context.data?.assumingMemoryBound(to: UInt8.self){
                
                for r in 0 ..< h {
                    for c in 0 ..< w {
                        if (mat[r][c]){
                            pixelBuffer[r*w+c] = 0
                        }else{
                            pixelBuffer[r*w+c] = 255
                        }
                    }
                }
                
                let cgImage = context.makeImage()!
                
                return UIImage(cgImage: cgImage)
            }else{
                print("Error extracting Matrix from grey scale")
                return nil
            }

        }else{
            print("Error creating context data buffer for new image.")
            return nil
        }
    }
}

//-----------------------------------------------------------------------------------------------------------------------------------

// extend UIImage to get pixel information
extension UIImage {
    // construct matrix from CGImage based UIImage
    func cgGetMatrix() -> Array<Array<Bool>>?{
        
        if let cg = self.cgImage{
            if let dp = cg.dataProvider{
                if let _ = dp.data{
                    print("Matrix extraction should work")
                }else{
                    print("Nil in extracting data from dataProvider")
                }
            }else{
                print("Nil in extracting dataProvider from cgimage")
            }
        }else{
            print("Nil in extracting cgImage from UIImage")
        }
        
        if let pixelData = self.cgImage?.dataProvider?.data {
            let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
            
            // parameters of the image
            let w = Int(self.size.width)
            let h = Int(self.size.height)
            // bigMat is the mapping of color to B&W for the whole image
            var mat = Array(repeating: Array(repeating: false, count: w), count: h)
            var vmat = Array(repeating: Array(repeating: 0, count: w), count: h)
            
            let thres = 75
            
            // fill bigMat by black(true) and white
            for i in 0 ..< h {
                for j in 0 ..< w {
                    let pixelInfo: Int = ((w*i) + j)
                    
                    let g = Int(data[pixelInfo]) // grey
                    
                    // print value of each point
                    // print("\(i),\(j): \(g)")
                    vmat[i][j] = g
                    
                    if ( g < thres) {
                        // print black values
                        // print(g)
                        mat[i][j] = true
                    }
                }
            }
            
            // print value matrix
//            for i in 0 ..< h {
//                for j in 0 ..< w {
//                    print("\(vmat[i][j]) ", terminator:"")
//                }
//                print("")
//            }
//
//            print("")
            
            // print resulting matrix
//            for i in 0 ..< h {
//                for j in 0 ..< w {
//                    if (mat[i][j]){
//                        print("1 ", terminator:"")
//                    }else{
//                        print("0 ", terminator:"")
//                    }
//
//                }
//                print("")
//            }
            return mat
        }else{
            print("Error extracting image dataProvider")
            return nil
        }
    }
}
