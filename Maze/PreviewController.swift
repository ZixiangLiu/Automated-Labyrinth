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

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var commentLabel: UILabel!
    var image: UIImage!
    var comment : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func update(){
        self.imageView.image = self.image
        self.commentLabel.text = self.comment
    }
    
}
