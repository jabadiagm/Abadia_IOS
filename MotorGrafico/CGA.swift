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
    
    //bitmap con número de color
    private var BitmapNcolorModo0=[UInt8](repeating: 0, count: 64000)
    private var BitmapNcolorModo1=[UInt8](repeating: 0, count: 49152)
    private let ColoresFirmware:[Color]=[
        Color(r: 0x00, g: 0x00, b: 0x00), //0
        Color(r: 0x00, g: 0x00, b: 0x80), //1
        Color(r: 0x00, g: 0x00, b: 0xff), //2
        Color(r: 0x80, g: 0x00, b: 0x00), //3
        Color(r: 0x80, g: 0x00, b: 0x80), //4
        Color(r: 0x80, g: 0x00, b: 0xff), //5
        Color(r: 0xff, g: 0x00, b: 0x00), //6
        Color(r: 0xff, g: 0x00, b: 0x80), //7
        Color(r: 0xff, g: 0x00, b: 0xff), //8
        Color(r: 0x00, g: 0x80, b: 0x00), //9
        Color(r: 0x00, g: 0x80, b: 0x80), //10
        Color(r: 0x00, g: 0x80, b: 0xf0), //11
        Color(r: 0x80, g: 0x80, b: 0x00), //12
        Color(r: 0x80, g: 0x80, b: 0x80), //13
        Color(r: 0x80, g: 0x80, b: 0xff), //14
        Color(r: 0xff, g: 0x80, b: 0x00), //15
        Color(r: 0xff, g: 0x80, b: 0x80), //16
        Color(r: 0xff, g: 0x80, b: 0xff), //17
        Color(r: 0x00, g: 0xff, b: 0x00), //18
        Color(r: 0x00, g: 0xff, b: 0x80), //19
        Color(r: 0x00, g: 0xff, b: 0xff), //20
        Color(r: 0x80, g: 0xff, b: 0x00), //21
        Color(r: 0x80, g: 0xff, b: 0x80), //22
        Color(r: 0x80, g: 0xff, b: 0xff), //23
        Color(r: 0xff, g: 0xff, b: 0x00), //24
        Color(r: 0xff, g: 0xff, b: 0x80), //25
        Color(r: 0xff, g: 0xff, b: 0xff)  //26
        ]
    private var cColores:[Color]=[Color](repeating: Color(r: 0x00, g: 0x00, b: 0x00), count: 16)
    
    private var ColorBorde:Int=0
    
    var bitmapModo0:Bitmap=Bitmap(width: 320, height: 200, color: .black)
    var bitmapModo1:Bitmap=Bitmap(width: 256, height: 192, color: .black)
    var modo:UInt8=0
    init () {
            /*let dibujo1=UIImage(imageLiteralResourceName: "Presentacion.png")
            bitmapModo0=Bitmap(image: dibujo1)!
            let dibujo2=UIImage(imageLiteralResourceName: "Screenshot.png")
            bitmapModo1=Bitmap(image: dibujo2)! */
    }
    
    func definirModo(modo: UInt8) {
        self.modo=modo
        
    }
    
    func SeleccionarPaleta( _ Paleta:Int) {
        switch Paleta {
            case  0: // paleta negra
                    ColorBorde = 0 //negro
                    cColores[0] = ColoresFirmware[0] //negro
                    cColores[1] = ColoresFirmware[0] //negro
                    cColores[2] = ColoresFirmware[0] //negro
                    cColores[3] = ColoresFirmware[0] //negro
            case 1: //pergamino
                    ColorBorde = 0x7D //rojo sangre
                    cColores[0] = ColoresFirmware[16] //rosa
                    cColores[1] = ColoresFirmware[0]  //negro
                    cColores[2] = ColoresFirmware[3]  //rojo sangre
                    cColores[3] = ColoresFirmware[6]  //rojo
            case 2: //día
                    cColores[0] = ColoresFirmware[10] //azul turquesa
                    cColores[1] = ColoresFirmware[25] //amarillo
                    cColores[2] = ColoresFirmware[15] //naranja
                    cColores[3] = ColoresFirmware[0]  //negro
            case 3: //noche
                    ColorBorde = 0 //negro
                    cColores[0] = ColoresFirmware[1]  //azul oscuro
                    cColores[1] = ColoresFirmware[13] //gris
                    cColores[2] = ColoresFirmware[5]  //morado
                    cColores[3] = ColoresFirmware[0]  //negro
            case 4: //presentación
                    cColores[0] = ColoresFirmware[16]
                    cColores[1] = ColoresFirmware[0]
                    cColores[2] = ColoresFirmware[26]
                    cColores[3] = ColoresFirmware[25]
                    cColores[4] = ColoresFirmware[10]
                    cColores[5] = ColoresFirmware[6]
                    cColores[6] = ColoresFirmware[1]
                    cColores[7] = ColoresFirmware[2]
                    cColores[8] = ColoresFirmware[8]
                    cColores[9] = ColoresFirmware[7]
                    cColores[10] = ColoresFirmware[15]
                    cColores[11] = ColoresFirmware[5]
                    cColores[12] = ColoresFirmware[13]
                    cColores[13] = ColoresFirmware[3]
                    cColores[14] = ColoresFirmware[14]
                    cColores[15] = ColoresFirmware[23]
            default:
                break
        }
        CopiarBitmapFirmware()
    }
    
    func InicializarPantalla() {
        SeleccionarPaleta(0)
    }
    
    func DibujarRectangulo( _ X1:Int, _ Y1:Int, _ X2:Int, _ Y2:Int, _ NColor: Int) {
        //var ContadorX:Int
        //var ContadorY:Int
        var StepX:Int = 1
        var StepY:Int = 1
        if X2 < X1  { StepX = -1 }
        if Y2 < Y1 { StepY = -1 }
        for ContadorX in stride(from: X1, to: X2+StepX, by: StepX) {
            for ContadorY in stride(from: Y1, to: Y2+StepY, by: StepY) { //} Y1 To Y2 Step StepY
                DibujarPunto(ContadorX, ContadorY, NColor)
            }
        }
    }
    
    func DibujarRectanguloCGA(X1:Int, Y1:Int, X2:Int, Y2:Int, NColor:Int) {
        //usa los colores de la paleta
        DibujarRectangulo(X1, Y1, X2, Y2, NColor)
    }
    
    /*
    func DibujarPunto(X:Int, Y:Int,Color:Int) {
        cBitmap.SetPixel(X, Y, Color.FromArgb(0xFF000000 + ModFunciones.BGR2RGB(Color_)))
    }*/
    
    func DibujarPunto( _ X:Int, _ Y:Int, _ NColor:Int) {
        if modo == 0 {
            BitmapNcolorModo0[X + 320 * Y] = UInt8(NColor)
            bitmapModo0.pset(x: X, y: Y, color: cColores[NColor])
        } else {
            if X < 0 {
                let stop = true
            }
            if X < 0 || X > 255 || Y > 191 { return }
            BitmapNcolorModo1[X + 256 * Y] = UInt8(NColor)
            bitmapModo1.pset(x: X, y: Y, color: cColores[NColor])
        }
    }
    
    func CopiarBitmapFirmware() {
        //actualiza el bitmap RGB partiendo del bitmap firmware. usado tras un cambio de paleta
        //var ContadorX:Int
        //var ContadorY:Int
        var NColor:Int
        if modo == 0 {
            for ContadorY in 0...199 {
                for ContadorX in 0...319 {
                    NColor = Int(BitmapNcolorModo0[ContadorX + 320 * ContadorY])
                    bitmapModo0.pset(x: ContadorX, y: ContadorY, color: cColores[NColor])
                }
            }
        } else {
            for ContadorY in 0...191 {
                for ContadorX in 0...255 {
                    NColor = Int(BitmapNcolorModo1[ContadorX + 256 * ContadorY])
                    bitmapModo1.pset(x: ContadorX, y: ContadorY, color: cColores[NColor])
                }
            }
        }
        //Refrescar()
    }
    
    func PantallaCGA2PC(PunteroPantalla:Int, Color:UInt8) {
        //convierte la información de cga para dibujar en PC
        var Y:Int
        var X:Int
        var NColor:[Int]=[Int](repeating: 0, count:4) //cada byte de cga contiene información de 4 píxeles
        var Cociente:Int //múltiplo de 8
        var Resto:Int //0-7
        var Contador:Int
        Cociente = Int((PunteroPantalla & 0x7FF) / 0x50)
        //Resto = shr(PunteroPantalla, 11) And &H7&
        Resto = (PunteroPantalla >> 11) & 0x7
        Y = Cociente * 8 + Resto
        X = ((PunteroPantalla & 0x7FF) - Cociente * 0x50) * 4 //posición del pixel más a la izquierda
        //en modo 1, se desplaza para encajar en 256 píxeles
        if modo == 1 || modo == 2 {
            X = X - 32
        }
        //If X = 0 Then Stop
        //Color = b7 b6 b5 b4 b3 b2 b1 b0
        //Color Pixel1 = b7 b3
        //Color Pixel2 = b6 b2
        //Color Pixel3 = b5 b1
        //Color Pixel4 = b4 b0
        //pixel1
        Resto = 0
        if (Color & 0x80) != 0 { Resto = 2 }
        if (Color & 0x8) != 0  { Resto = Resto + 1 }
        NColor[0] = Resto
        //pixel2
        Resto = 0
        if (Color & 0x40) != 0  { Resto = 2 }
        if (Color & 0x4) != 0  { Resto = Resto + 1 }
        NColor[1] = Resto
        //pixel3
        Resto = 0
        if (Color & 0x20) != 0  { Resto = 2 }
        if (Color & 0x2) != 0  { Resto = Resto + 1 }
        NColor[2] = Resto
        //pixel4
        Resto = 0
        if (Color & 0x10) != 0  { Resto = 2 }
        if (Color & 0x1) != 0  { Resto = Resto + 1 }
        NColor[3] = Resto
        for Contador in 0...3 {
            DibujarPunto(X + Contador, Y, NColor[Contador])
        }
    }
    
}
