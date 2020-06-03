//
//  cWaveOut.swift
//  Abadia
//
//  Created by javier on 17/03/2020.
//  Copyright © 2020 Phillip LAcebo. All rights reserved.
//

import Foundation
class WaveOut {
    var Sonido:Reproducible?
    var Cancelar:Bool=false
    var Thread1:Thread?
    let reloj:StopWatch=StopWatch()
    func Init (Sonido:Reproducible) {
        self.Sonido=Sonido

    }
    
    func Reproducir() {
        Cancelar=false
        reloj.Start()
        Thread1 = Thread(target:self, selector:#selector(Tarea), object:nil)
        Thread1?.start()
    }
    
    func Parar() {
        
    }
    
    func Abrir() {
        
    }
    
    func Cerrar () {
        
    }
    
    private func Tics2Bytes(Tics:UInt32) -> UInt32 {
        return 0
    }
    
    @objc func Tarea() {
        var nose:Float
        struct estatico {
            static var contador:UInt32=0
        }
        repeat {
            nose=Sonido!.Reproducir()
            nose=nose+1
            usleep(1000)
            estatico.contador+=1
            if reloj.EllapsedMilliseconds() >= 1000 {
                reloj.Start()
                print ("Wave:\(estatico.contador)")
                estatico.contador = 0
            }


        } while (true)
        
    }
    
    
}
