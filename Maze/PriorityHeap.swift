//
//  PriorityHeap.swift
//  Maze
//
//  Created by Zixiang Liu on 3/25/18.
//  Copyright © 2018 Zixiang Liu. All rights reserved.
//

import Foundation

// preperation for dijkstra algorithm
// not used in this version

// indicate whether it is left or right child of parent
enum sibling {
    case left
    case right
}

class queueNode: Equatable {
    
    var value: PixelNode
    var leftChild: queueNode?
    var rightChild: queueNode?
    var parent: queueNode?
    var brotherHood: sibling?
    
    init(pixelNode p: PixelNode) {
        self.value = p
        self.parent = nil
        self.leftChild = nil
        self.rightChild = nil
        self.brotherHood = nil
    }
    
    func getWeight() -> Int {
        return self.value.getWeight()
    }
    
    func assignParent(parentNode p: queueNode, brotherhood b: sibling) {
        self.parent = p
        self.brotherHood = b
    }
    
    func assignPrevious(parentNode p: queueNode) {
        self.value.previousNodeR = p.value.row
        self.value.previousNodeC = p.value.column
    }
    
    func swap(queueNode q: queueNode) {
        let tempLeft = q.leftChild
        let tempRight = q.rightChild
        let tempParent = q.parent
        let tempBrotherHood = q.brotherHood
        
        q.leftChild = self.leftChild
        q.rightChild = self.rightChild
        q.parent = self.parent
        q.brotherHood = self.brotherHood
        if let left = q.leftChild {
            left.parent = q
        }
        if let right = q.rightChild {
            right.parent = q
        }
        if let parent = q.parent {
            if q.brotherHood == .left {
                parent.leftChild = q
            }else if q.brotherHood == .right {
                parent.rightChild = q
            }
        }
        
        self.leftChild = tempLeft
        self.rightChild = tempRight
        self.parent = tempParent
        self.brotherHood = tempBrotherHood
        if let left = self.leftChild {
            left.parent = self
        }
        if let right = self.rightChild {
            right.parent = self
        }
        if let parent = self.parent {
            if self.brotherHood == .left {
                parent.leftChild = self
            }else if self.brotherHood == .right {
                parent.rightChild = self
            }
        }
    }
    
    static func ==(lhs: queueNode, rhs: queueNode) -> Bool {
        return lhs.value == rhs.value
    }
}

// enum for keep track of min
enum minNode {
    case left
    case right
    case parent
}

// linked priority queue,
class PriorityQueue {
    var root: queueNode? // root
    var last: queueNode? // node who should accept the next insert to be a child
    var lastSibling: sibling? // which sibling the new insert should be
    
    init(){
        self.root = nil
        self.last = nil
        self.lastSibling = nil
    }
    
    // if not root -> empty
    func isEmpty() -> Bool {
        if let _ = self.root {
            return false
        }else{
            return true
        }
    }
    
    // insert
    func insert(pixelNode p: PixelNode) {
        p.mark()
        let newNode = queueNode(pixelNode: p)
        if self.isEmpty(){
            // insert to root
            self.root = newNode
            self.last = newNode
            self.lastSibling = .left
        }else{
            if (self.lastSibling! == .left) {
                // insert to left
                self.lastSibling = .right
                self.last!.leftChild = newNode
                newNode.assignParent(parentNode: self.last!, brotherhood: .left)
                minHeapify(queueNode: self.last!)
            }else{
                // insert to next right
                self.lastSibling = .left
                self.last!.rightChild = newNode
                newNode.assignParent(parentNode: self.last!, brotherhood: .right)
                minHeapify(queueNode: self.last!)
                
                // find next last node
                // find rightmost left child which is also an ancestor of newNode
                while (self.last!.brotherHood == .right) {
                    self.last = self.last!.parent
                }
                // find the right sibling
                // in case of root, stay there
                if let grandparent = self.last!.parent{
                    self.last = grandparent.rightChild
                }
                // find the left most, deepest node
                while (self.last!.leftChild != nil) {
                    self.last = self.last!.leftChild
                }
            }
        }
    }
    
    // pop min
    func popMin() -> PixelNode? {
        if self.isEmpty() {
            print("Error poping empty queue")
            return nil
        }
        let minPixel = self.root!.value
        
        if (self.lastSibling == .right) {
            self.lastSibling = .left
            let newRoot = self.last!.leftChild!.value
            self.last!.leftChild = nil
            self.root!.value = newRoot
            minHeapify(queueNode: self.root!)
        }else{
            if self.last! == self.root!{
                // only one node
                self.last = nil
                self.root = nil
                self.lastSibling = nil
            }else{
                self.lastSibling = .right
                // find preivous last node
                // find leftmost right child which is also an ancestor of newNode
                while (self.last!.brotherHood == .left) {
                    self.last = self.last!.parent
                }
                // find the left sibling
                // in case of root, stay there
                if let grandparent = self.last!.parent {
                    self.last = grandparent.leftChild
                }
                // find the left most, deepest node's parent
                while (self.last!.rightChild != nil) {
                    self.last = self.last!.rightChild
                }
                let newRoot = self.last!.value
                self.last = self.last!.parent
                self.last!.rightChild = nil
                self.root!.value = newRoot
                minHeapify(queueNode: self.root!)
            }
        }
        
        return minPixel
    }
    
    // min heapify
    func minHeapify(queueNode q: queueNode) {
        var minN = minNode.parent
        var minQueueNode = q
        
        if let left = q.leftChild {
            if (left.getWeight() < q.getWeight()) {
                minN = .left
                minQueueNode = left
            }
        }
        
        if let right = q.rightChild {
            if (right.getWeight() < minQueueNode.getWeight()) {
                minN = .right
                minQueueNode = right
            }
        }
        
        if (minN != .parent) {
            minQueueNode.swap(queueNode: q)
            minHeapify(queueNode: minQueueNode)
        }
    }
    
    func contains(pixelNode p: PixelNode) -> Bool {
        if self.isEmpty() {
            return false
        }else{
            return compare(queueNode: self.root!, pixelNode: p)
        }
    }
    
    func compare(queueNode q: queueNode, pixelNode p: PixelNode) -> Bool{
        if q.value == p {
            return true
        }else{
            if let left = q.leftChild {
                if compare(queueNode: left, pixelNode: p) {
                    return true
                }
            }else{
                if let right = q.rightChild {
                    if compare(queueNode: right, pixelNode: p) {
                        return true
                    }
                }else{
                    return false
                }
            }
        }
        return false
    }
}
