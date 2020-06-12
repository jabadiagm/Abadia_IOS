//
//  Depuracion.swift
//  Abadia
//
//  Created by javier on 02/04/2020.
//  Copyright © 2020 javier abadía. All rights reserved.
//

import Foundation

public enum EnumTipoLuz {
    case EnumTipoLuz_Normal
    case EnumTipoLuz_ON
    case EnumTipoLuz_Off
}

class Depuracion {
    public var PersonajesAdso:Bool
    public var PersonajesMalaquias:Bool
    public var PersonajesAbad:Bool
    public var PersonajesBerengario:Bool //berengario/bernardo gui/encapuchado/jorge
    public var PersonajesSeverino:Bool //severino/jorge
    public var LuzEnGuillermo:Bool
    public var Lampara:Bool //lámpara siempre disponible
    public var DeshabilitarCalculoDimensionesAmpliadas:Bool //true para evitar el uso de la función CalcularDimensionesAmpliadasSprite_4CBF
    public var Luz:EnumTipoLuz
    public var QuitarRetardos:Bool
    public var SaltarPergamino:Bool
    public var SaltarPresentacion:Bool
    public var PararAdsoCTRL:Bool //permitir parar a Adso al pulsar Control
    public var SaltarMomentoDiaEnter:Bool //permitir pasar el momento del día pulsando Enter
    public var BugDejarObjetoPresente:Bool //habilita el bug que toma una orientación incorrecta al dejar objeto
    public var PuertasAbiertas:Bool //permite atravesar las puertas
    public var CamaraManual:Bool //true para sobreescribir el personaje al que apunta la camara
    public var CamaraPersonaje:UInt8=0 //número de personaje al que sigue la cámara, si CamaraManual=true
    //                               0 = Guillermo, 1 = Adso, 2 = Malaquías, 3 = Abad, 4 = Berengario, 5 = Severino
    public var QuitarSonido:Bool
    public var PergaminoNoDesaparece:Bool //true para que no desaparezca el tercer día si no lo tiene guillermo
    public var PaseoGuillermo:Bool //true para que guillermo ande solo
    
    public func Check() {
        Luz = EnumTipoLuz.EnumTipoLuz_ON
        LuzEnGuillermo = false
        Lampara = false
        PersonajesAdso = true
        PersonajesMalaquias = true
        PersonajesAbad = true
        PersonajesBerengario = true
        PersonajesSeverino = true
        DeshabilitarCalculoDimensionesAmpliadas = false
        QuitarRetardos = false
        SaltarPergamino = true
        SaltarPresentacion = true
        PararAdsoCTRL = true
        SaltarMomentoDiaEnter = true
        BugDejarObjetoPresente = false
        PuertasAbiertas = false
        PergaminoNoDesaparece = false
        PaseoGuillermo = false
        QuitarSonido = true
    }

    init() {
        Luz = EnumTipoLuz.EnumTipoLuz_Normal
        LuzEnGuillermo = false
        Lampara = false
        PersonajesAdso = true
        PersonajesMalaquias = true
        PersonajesAbad = true
        PersonajesBerengario = true
        PersonajesSeverino = true
        DeshabilitarCalculoDimensionesAmpliadas = false
        QuitarRetardos = false
        SaltarPergamino = false
        SaltarPresentacion = false
        PararAdsoCTRL = false
        SaltarMomentoDiaEnter = true
        BugDejarObjetoPresente = true
        PuertasAbiertas = false
        CamaraManual = false
        PergaminoNoDesaparece = false
        PaseoGuillermo = false
        QuitarSonido = false
    }
}
