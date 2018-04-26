//
//  PreviewController.swift
//  Maze
//
//  Created by Zixiang Liu on 2/28/18.
//  Copyright © 2018 Zixiang Liu. All rights reserved.
//

import Foundation
import UIKit

class PreviewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate{

    @IBOutlet weak var mazeImageView: UIImageView!
    @IBOutlet weak var wholeImageView: UIImageView!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var wbSlider: UISlider!
    
    var smallImage: UIImage!
    var maze = Maze()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.update()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func changeWB(_ sender: UISlider) {
        if (!sender.isTracking) {
            print(sender.value)
            maze.setWall(ballWidth: Int(sender.value))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier=="MatrixView"){
            let destination = segue.destination as! MatrixController
            destination.maze = self.maze
        }
    }
    
    func update(){
        self.mazeImageView.image = self.maze.mazeImage
        self.wholeImageView.image = self.maze.wholeImage
        self.commentLabel.text = self.maze.comment
    }
    
}
