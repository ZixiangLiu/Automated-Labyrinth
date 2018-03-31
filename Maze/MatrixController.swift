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
            if let image = self.maze.getColorRouteImage(startX: 50, startY: 50, endX: 570, endY: 570) {
                self.sharpImageView.image = image
            }else{
                self.sharpImageView.image = #imageLiteral(resourceName: "huaji")
            }
        }
        else{
            self.matrixImageView.image = #imageLiteral(resourceName: "huaji")
        }
    }
    
    @IBAction func launchBluetooth() {
        let decodedURL = "serial://" + self.maze.matrixToString(myArray: maze.getBTRouteArray())
        let alertPrompt = UIAlertController(title: "Open App", message: "You're going to open \(decodedURL)", preferredStyle: .actionSheet)
        let confirmAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            //            let url = URL(string: decodedURL)
            //            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            if let url = URL(string: decodedURL) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        
        alertPrompt.addAction(confirmAction)
        alertPrompt.addAction(cancelAction)
        
        present(alertPrompt, animated: true, completion: nil)
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}
