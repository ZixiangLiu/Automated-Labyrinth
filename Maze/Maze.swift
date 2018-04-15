//
//  Maze.swift
//  Maze
//
//  Created by Zixiang Liu on 2/28/18.
//  Copyright © 2018 Zixiang Liu. All rights reserved.
//

// Important!!!!***************************************************************************************************
// use getColorRouteImage first to calculate routeArray and conciseRouteArray
// x is row, y is column
// conciseRouteArray is the array of yellow points on graph
// each viewController has a maze object, and they should all refer to the same thing
// Important!!!!***************************************************************************************************

import Foundation
import UIKit

class Maze{
    // the cropped and corrected matrix image
    var mazeImage: UIImage!
    // the whole image taken by camera
    var wholeImage: UIImage!
    // small image in grey scale
    var greyImage: UIImage?
    // transfromed and downscaled maze image
    var smallImage: UIImage!
    // image of matrix color is black(0) or white(255)
    var matrixImage: UIImage!
    // comment from ViewController, found or didn't find square
    var comment: String!
    // route in red with walls in black
    var routeImage: UIImage!
    // route
    var routeArray: [[Int]] = []
    // route array of only turning points
    var conciseRouteArray: [[Int]] = []
    // route array of only turning points
    var BTRouteArray: [[Int]] = []
    
    // width of matrix
    let w = 600
    // height of matrix
    let h = 600
    // width of matrix used in route calculation
    let rw = 200
    // height of matrix used in route calculation
    let rh = 200
    // width of ball
    let wb = 15
    // size of start and end mark
    let sizeSE = 15
    // width of route
    let wr = 4
    // used to create CI context
    let bitmapInfo = CGBitmapInfo().rawValue
    let colorBitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
    let greyColorSpace = CGColorSpaceCreateDeviceGray()
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    // the matrix form of the maze
    var mat: Array<Array<Bool>>!
    
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
        let context = CGContext(data: nil, width: w, height: h, bitsPerComponent: 8, bytesPerRow: w, space: greyColorSpace, bitmapInfo: bitmapInfo)
        if let cont = context{
            cont.draw(self.smallImage.cgImage!, in: CGRect(x: 0, y: 0, width: w, height: h))
        }else{
            print("Nil context")
        }
        
        let mask = context!.makeImage()!
        self.greyImage = UIImage(cgImage: mask)
    }
    
    // use this method to get the matrix of the maze grey scale
    func getMatrix() -> Array<Array<Bool>>? {
        if let mat = self.mat{
            return mat
        }else{
            if let grey = self.greyImage {
                self.mat = grey.cgGetMatrix()
            }else{
                self.convertToGrayScale()
                self.mat = self.getMatrix()
            }
            return self.mat
        }
    }
    
    // Use this method to get the matrix image of the maze grey scale
    func getGreyMatrixImage() -> UIImage? {
        if let image = self.matrixImage{
            return image
        }else{
            if let mat = self.getMatrix(){
                let context = CGContext(data: nil, width: w, height: h, bitsPerComponent: 8, bytesPerRow: w, space: greyColorSpace, bitmapInfo: bitmapInfo)!
                
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
                    self.matrixImage = UIImage(cgImage: cgImage)
                    return self.matrixImage
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
    
    func validRow(Row r: Int) -> Bool {
        return (r > -1 && r < rh)
    }
    
    func validColumn(Column c: Int) -> Bool {
        return (c > -1 && c < rw)
    }
    
    // use the matrix to calculate route out of the maze
    func calculateRoute(startX sx: Int, startY sy: Int, endX ex: Int, endY ey: Int){
        // pixel matrix
        var matGraph: [[PixelNode]] = []
        var pQueue: Array<PixelNode> = Array()
        
        let mat = self.getMatrix()!
        var routeMat = Array(repeating: Array(repeating: 0, count: rw), count: rh)
        let sf = Int(h/rh) // scale factor
        
        // initialize route matrix, a smaller version of the matrix
        for r in 0 ..< rh {
            for c in 0 ..< rw {
                for i in sf*r ..< sf*(r+1){
                    for j in sf*c ..< sf*(c+1){
                        if mat[i][j] {
                            routeMat[r][c] = routeMat[r][c]+1
                        }
                    }
                }
            }
        }
        
        // initialize graph
        for r in 0 ..< rh {
            var oneRow: [PixelNode] = []
            for c in 0 ..< rw {
                oneRow.append(PixelNode(Row: r, Column: c, ballWidth: wb))
            }
            matGraph.append(oneRow)
        }
        
        // set wall distance
        for r in 0 ..< rh {
            for c in 0 ..< rw {
                if (routeMat[r][c] > 0){
                    for l in max(0, r-2*wb) ... min(rh-1, r+2*wb) {
                        for k in max(0, c-2*wb) ... min(rw-1, c+2*wb) {
                            matGraph[l][k].setDistWall(wallRoll: r, wallColumn: c)
                        }
                    }
                }
            }
        }
        
        // bfs
        let rex = Int(ex/sf)
        let rey = Int(ey/sf)
        let _ = matGraph[rex][rey].setDistStart(distStart: 0)
        pQueue.append(matGraph[rex][rey])
        
        while (!pQueue.isEmpty){
            let p = pQueue.removeFirst()
            
            let r = p.row
            let c = p.column
            
            // vertical and horizontal neighbor
            let vhNeighbor = [[r-1, c], [r+1, c], [r, c-1], [r, c+1]]
            // diagonal
            let dNeighbor = [[r-1, c-1], [r-1, c+1], [r+1, c-1], [r+1, c+1]]
            
            var edgeWeight = 2
            
            for np in vhNeighbor {
                if (validRow(Row: np[0]) && validColumn(Column: np[1])){
                    let n = matGraph[np[0]][np[1]]
                    if (!n.marked && n.valid()){
                        if (n.setDistStart(distStart: p.distStart + edgeWeight)) {
                            n.setPrevious(previousRow: p.row, previousColumn: p.column)
                        }
                        pQueue.append(n)
                        n.mark()
                    }
                }
            }
            
            edgeWeight = 3
            
            for np in dNeighbor {
                if (validRow(Row: np[0]) && validColumn(Column: np[1])){
                    let n = matGraph[np[0]][np[1]]
                    if (!n.marked && n.valid()){
                        if (n.setDistStart(distStart: p.distStart + edgeWeight)) {
                            n.setPrevious(previousRow: p.row, previousColumn: p.column)
                        }
                        pQueue.append(n)
                        n.mark()
                    }
                }
            }
            
//            for r in max(0, p.row-1) ... min(p.row+1, h-1) {
//                for c in max(0, p.column-1) ... min(p.column+1, w-1) {
//                    let n = matGraph[r][c]
//                    if (!n.marked && n.valid()){
//
//                        let diff = abs(r-p.row)+abs(c-p.column)
//                        if (diff == 2){ // if diagonal neighbour
//
//                        }
//
//                        if (n.setDistStart(distStart: p.distStart + edgeWeight)) {
//                            n.setPrevious(previousRow: p.row, previousColumn: p.column)
//                        }
//                        pQueue.append(n)
//                        n.mark()
//                    }
//                }
//            }
            
            

        }
        
        var route: [[Int]] = []
        var xp = Int(sx/sf)
        var yp = Int(sy/sf)
        let hsf = Int(sf/2)
        while (matGraph[xp][yp].previousNodeC != -1) {
            route.append([xp*sf+hsf, yp*sf+hsf])
            let r = matGraph[xp][yp].previousNodeR
            let c = matGraph[xp][yp].previousNodeC
            xp = r
            yp = c
        }
        route.append([ex, ey])
        self.routeArray = route
    }
    
    func easyDist(point1 p1: [Int], point2 p2: [Int]) -> Int {
        return abs(p1[0]-p2[0])+abs(p1[1]-p2[1])
    }
    
    func getConciseArray() -> [[Int]]{
        if self.conciseRouteArray.isEmpty {
            var tempArray: [[Int]] = []
            var preDirect = 0
            var prePoint = self.routeArray[0]
            for i in 0 ..< routeArray.count-1 {
                let this = routeArray[i]
                let next = routeArray[i+1]
                let dr = this[0] - next[0]
                let dc = this[1] - next[1]
                let direct = 10*dr + dc
                if (direct != preDirect || easyDist(point1: prePoint, point2: this) > 100) {
                    tempArray.append(this)
                    preDirect = direct
                    prePoint = this
                }
            }
            
            if tempArray.isEmpty{
                print("No route available")
            }else{
                prePoint = tempArray[0]
                // start point
                self.conciseRouteArray.append(prePoint)
                // get rid of too crowded middle points
                for i in 1 ..< tempArray.count {
                    let current = tempArray[i]
                    if (easyDist(point1: prePoint, point2: current) > 15) {
                        prePoint = current
                        self.conciseRouteArray.append(current)
                    }
                }
                // end point
                self.conciseRouteArray.append(routeArray[routeArray.count-1])
            }
            
            return self.conciseRouteArray
        }else{
            return self.conciseRouteArray
        }
    }
    
    func getBTRouteArray() -> [[Int]] {
        if self.BTRouteArray.isEmpty{
            let cta = self.getConciseArray()
            for p in cta {
                self.BTRouteArray.append([Int(Double(p[1])*1.382)+130, Int(Double(p[0])*1.48)+90])
            }
            return self.BTRouteArray
        }else{
            return self.BTRouteArray
        }
    }
    
    // Use this method to get the matrix image of the maze grey scale
    // x is row, y is column
    func getColorRouteImage(startX sx: Int, startY sy: Int, endX ex: Int, endY ey: Int) -> UIImage? {
        if let image = self.routeImage{
            return image
        }else{
            if self.routeArray.isEmpty {
                self.calculateRoute(startX: sx, startY: sy, endX: ex, endY: ey)
            }
            if let mat = self.getMatrix(){
                let context = CGContext(data: nil, width: w, height: h, bitsPerComponent: 8, bytesPerRow: w*4, space: colorSpace, bitmapInfo: colorBitmapInfo)!
                
                if let pixelBuffer = context.data?.assumingMemoryBound(to: UInt8.self){
                    
                    for r in 0 ..< h {
                        for c in 0 ..< w {
                            let p = (r*w+c)*4
                            
                            if (mat[r][c]){
                                // black wall
                                pixelBuffer[p] = 0
                                pixelBuffer[p+1] = 0
                                pixelBuffer[p+2] = 0
                                pixelBuffer[p+3] = 255
                            }else{
                                // white ground
                                pixelBuffer[p] = 255
                                pixelBuffer[p+1] = 255
                                pixelBuffer[p+2] = 255
                                pixelBuffer[p+3] = 255
                            }
                        }
                    }
                    
                    // red start
                    for r in max(0, sx-sizeSE) ... min(h-1, sx+sizeSE) {
                        for c in max(0, sy-sizeSE) ... min(w-1, sy+sizeSE) {
                            let p = (r*w+c)*4
                            
                            pixelBuffer[p] = 255
                            pixelBuffer[p+1] = 0
                            pixelBuffer[p+2] = 0
                        }
                    }
                    
                    // green end
                    for r in max(0, ex-sizeSE) ... min(h-1, ex+sizeSE) {
                        for c in max(0, ey-sizeSE) ... min(w-1, ey+sizeSE) {
                            let p = (r*w+c)*4
                            
                            pixelBuffer[p] = 0
                            pixelBuffer[p+1] = 255
                            pixelBuffer[p+2] = 0
                        }
                    }
                    
                    // blue route
                    for point in self.routeArray{
                        for r in max(0, point[0]-wr) ... min(h-1, point[0]+wr) {
                            for c in max(0, point[1]-wr) ... min(w-1, point[1]+wr) {
                                let p = (r*w+c)*4
                                
                                pixelBuffer[p] = 0
                                pixelBuffer[p+1] = 0
                                pixelBuffer[p+2] = 255
                            }
                        }
                    }
                    
                    // yellow route turning point
                    for point in self.getConciseArray() {
                        for r in max(0, point[0]-wr) ... min(h-1, point[0]+wr) {
                            for c in max(0, point[1]-wr) ... min(w-1, point[1]+wr) {
                                let p = (r*w+c)*4
                                
                                pixelBuffer[p] = 255
                                pixelBuffer[p+1] = 255
                                pixelBuffer[p+2] = 0
                            }
                        }
                    }
                    
                    let cgImage = context.makeImage()!
                    self.matrixImage = UIImage(cgImage: cgImage)
                    return self.matrixImage
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
    
    // convert matrix to string
    func matrixToString(myArray: [[Int]]) -> String {
        var outputString = "s"
        for i in 0...myArray.count-1 {
            for j in 0...myArray[0].count-1 {
                outputString += String(format: "%03d", myArray[i][j]) + ","
            }
        }
        outputString += "e"
        return outputString
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
            
            // threshold to detect black
            let thres = 100
            
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
