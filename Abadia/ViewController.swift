//
//  ViewController.swift
//  Abadia
//
//  Created by Phillip LAcebo on 07/10/2017.
//  Copyright © 2017 Phillip LAcebo. All rights reserved.
//

import UIKit


class ViewController: UIViewController {
    let cgaController=CGAController()
    let inputController=InputController()
    let abadia=Abadia()

    let reloj:StopWatch=StopWatch()
    let reloj2:StopWatch=StopWatch()
    var contador:UInt32=0
    var contador2:UInt32=0
    var fps2:UInt8=0
    var toneOutputUnit:ToneOutputUnit=ToneOutputUnit()
    var PruebaSonido=cPruebaSonido()
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpImageView()
 
        abadia.Init(cCGAController: cgaController, cImageView: imageView, cViewController: self)
        
        reloj.Start()
        cgaController.drawSomething()
        reloj.Stop()
        
        let displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink.add(to: .current, forMode: .common)

        print (reloj.EllapsedMicroseconds())
        
        let thread = Thread(target:self, selector:#selector(tarea2), object:nil)
        thread.start()
        
        //toneOutputUnit.enableSpeaker()
        //toneOutputUnit.setToneTime(t: 30)
        PruebaSonido.Reproducir()
        
   
        

        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func setUpImageView() {
        //define las restricciones del control UIImageView para que ocupe toda la pantalla
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .black
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        abadia.DefinirModo(Modo: 1)
    }
    
    
    @objc func update() {
        
        reloj.Start()
        cgaController.Nose()
        if (contador%2)==1 {
            abadia.RefrescarPantalla2()
        }
        reloj.Stop()
       
        contador+=1
        if contador>59 {
            //reloj.Start()
            //cgaController.LLenarPantalla()
            //reloj.Stop()
             print (reloj.EllapsedMicroseconds()/1000)
            contador=0
        }
    }
    
  
    @objc func tarea2() {
        var fps2:UInt32=0
        reloj2.Start()
        repeat {
            fps2+=1
            if reloj2.EllapsedMicroseconds()>=1000000 {
                //print(fps2)
                fps2=0
                reloj2.Start()
            }
            usleep(10000)
        } while true
    }
}

