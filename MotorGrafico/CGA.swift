//
//  CGA.swift
//  Abadia
//
//  Created by javier on 31/03/2020.
//  Copyright © 2020 javier abadía. All rights reserved.
//

import Foundation
import UIKit

class CGA {
    var bitmapModo0:Bitmap=Bitmap(width: 320, height: 200, color: .black)
    var bitmapModo1:Bitmap=Bitmap(width: 256, height: 192, color: .black)
    var modo:UInt8=0
    init () {
            let dibujo1=UIImage(imageLiteralResourceName: "Presentacion.png")
            bitmapModo0=Bitmap(image: dibujo1)!
            let dibujo2=UIImage(imageLiteralResourceName: "Screenshot.png")
            bitmapModo1=Bitmap(image: dibujo2)!
    }
    
    func definirModo(modo: UInt8) {
        self.modo=modo
        
    }
    
    func SeleccionarPaleta(Paleta:UInt32) {
        
    }
    
    func InicializarPantalla() {
        
    }
    
    func DibujarRectangulo(X1:UInt32, Y1:UInt32, X2:UInt32, Y2:UInt32) {
        
    }
    
    func DibujarRectanguloCGA(X1:UInt32, Y1:UInt32, X2:UInt32, Y2:UInt32, NColor:UInt8) {
        
    }
    
    func DibujarPunto(X:UInt32, Y:UInt32,Color:UInt32) {
        
    }
    
    func DibujarPunto(X:UInt32, Y:UInt32,NColor:UInt8) {
        
    }
    
    func CopiarBitmapFirmware() {
        
    }
    
    func PantallaCGA2PC(PunteroPantalla:UInt32, Color:UInt8) {
        
    }
    
}
