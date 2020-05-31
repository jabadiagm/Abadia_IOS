//
//  ViewController.swift
//  Abadia
//
//  Created by Phillip LAcebo on 07/10/2017.
//  Copyright © 2017 Phillip LAcebo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let abadia=Abadia()
    let cgaController=CGAController()
    let inputController=InputController()
    
   
    @IBOutlet weak var imageView: UIImageView!
    
    
    override func viewDidLoad() {


        super.viewDidLoad()
        cgaController.drawSomething()
        abadia.SetObjects(cCGAController: cgaController, cImageView: imageView, cViewController: self)
        abadia.ComposeView()

        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

