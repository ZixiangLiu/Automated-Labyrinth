//
//  PixelNode.swift
//  Maze
//
//  Created by Zixiang Liu on 3/24/18.
//  Copyright © 2018 Zixiang Liu. All rights reserved.
//

import Foundation

// this class is nodes in graph
// also includes methods make BFS convenient

class PixelNode: Equatable {
    
    let row: Int
    let column: Int
    var distWall: Int // min distance to wall
    var distStart: Int // min distance to start point
    var ballWidth: Int // width of ball
    var previousNodeR: Int
    var previousNodeC: Int
    var marked = false
    let INFI = Int(UInt16.max)
    let NINFI = -Int(UInt16.max)
    
    
    init(Row r: Int, Column c: Int, ballWidth bw: Int){
        self.row = r
        self.column = c
        self.distWall = INFI
        self.distStart = INFI
        self.ballWidth = bw*bw
        self.previousNodeR = -1
        self.previousNodeC = -1
    }
    
    // set distance to wall
    func setDistWall(wallRoll wr: Int, wallColumn wc: Int){
        if self.distWall >= self.ballWidth{
            let rDiff = (wr - self.row)*(wr - self.row)
            let cDiff = (wc - self.column)*(wc - self.column)
            let dist = rDiff + cDiff
            self.distWall = min(self.distWall, dist)
        }
    }
    
    func setStart() {
        self.distStart = 0
    }
    
    func setDistStart(distStart ds: Int) -> Bool{
        if self.distStart > ds {
            self.distStart = ds
            return true
        }
        return false
    }
    
    func setPrevious(previousRow r: Int, previousColumn c: Int){
        self.previousNodeR = r
        self.previousNodeC = c
    }
    
    func getWeight() -> Int {
        return self.distStart-distWall
    }
    
    func valid() -> Bool {
        if self.distWall < ballWidth {
            return false
        }
        return true
    }
    
    func mark(){
        self.marked = true
    }
    
    func uniqueCode() -> Int{
        return self.row * 1000 + self.column
    }
    
    static func ==(lhs: PixelNode, rhs: PixelNode) -> Bool {
        return lhs.uniqueCode() == rhs.uniqueCode()
    }
}
