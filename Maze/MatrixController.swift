//
//  Matrix.swift
//  Maze
//
//  Created by Zixiang Liu on 2/28/18.
//  Copyright © 2018 Zixiang Liu. All rights reserved.
//

import Foundation
import UIKit

class MatrixController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    
    @IBOutlet weak var matrixImageView: UIImageView!
    @IBOutlet weak var sharpImageView: UIImageView!
    var maze = Maze()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.maze.resize()
        if (self.maze.smallImage) != nil{
            self.maze.convertToGrayScale()
            self.matrixImageView.image = self.maze.greyImage
            if let image = self.maze.generateMatrixImage(){
                self.sharpImageView.image = image
            }else{
                self.sharpImageView.image = #imageLiteral(resourceName: "huaji")
            }
        }
        else{
            self.matrixImageView.image = #imageLiteral(resourceName: "huaji")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}
