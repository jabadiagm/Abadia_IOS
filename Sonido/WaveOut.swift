//
//  cWaveOut.swift
//  Abadia
//
//  Created by javier on 17/03/2020.
//  Copyright © 2020 javier abadía. All rights reserved.
//

import Foundation
import AVFoundation

class WaveOut {
    public static var WAVE_FREQ:Int=6000 //frecuencia de muestreo
    private let WAVE_BUFFER_SIZE:Int = 2000
    private var AudioEngine:AVAudioEngine
    private var Player:AVAudioPlayerNode
    private var Mixer:AVAudioMixerNode
    private var Buffer1:AVAudioPCMBuffer
    private var Buffer2:AVAudioPCMBuffer
    private var TareaActiva:Bool=false
    private var BytesPorTic:Float=0 //relación entre bytes y us
    private var WaveBuffer:DoubleBuffer
    public var PunteroFinBuffer:Int=0
    public var UltimoError:String = ""
    private var Abierto:Bool=false
    public var Reproduciendo:Bool=false
    private var Sonido:Reproducible?
    private var Cancelar:Bool=false
    private var Thread1:Thread?
    private let Reloj:StopWatch=StopWatch()
    private var Estado:UInt8=0
    private var BufferDepleted:Bool=false
    
    private var chivato:Int=0
    
    init (Sonido:Reproducible) {
        //audio source
        self.Sonido=Sonido
        
        //set audio objects
        WaveBuffer=DoubleBuffer(BufferSize: WAVE_BUFFER_SIZE)
        AudioEngine=AVAudioEngine()
        Player=AVAudioPlayerNode()
        Mixer=AudioEngine.mainMixerNode

        // setup audio engine
        AudioEngine.attach(Player)
        
        //un canal
        let AudioFormat=AVAudioFormat(standardFormatWithSampleRate: Double(WaveOut.WAVE_FREQ), channels: 1)
        AudioEngine.connect(Player, to: Mixer, format: AudioFormat)

        //buffers
        Buffer1 = AVAudioPCMBuffer(pcmFormat: AudioFormat!, frameCapacity: UInt32(WAVE_BUFFER_SIZE))!
        Buffer1.frameLength = UInt32(WAVE_BUFFER_SIZE)
        Buffer2 = AVAudioPCMBuffer(pcmFormat: AudioFormat!, frameCapacity: UInt32(WAVE_BUFFER_SIZE))!
        Buffer2.frameLength = UInt32(WAVE_BUFFER_SIZE)

        BytesPorTic = Float(WaveOut.WAVE_FREQ) / Float(1000000) //bytes por us

    }
    
    public func Reconectar() {
        
        
        AudioEngine.attach(Player)
        let AudioFormat=AVAudioFormat(standardFormatWithSampleRate: Double(WaveOut.WAVE_FREQ), channels: 1)
        AudioEngine.connect(Player, to: Mixer, format: AudioFormat)
        AudioEngine.prepare()
    }
  
    public func Pausar() {
        Player.pause()
    }
    
    public func Reproducir() {
        if !AudioEngine.isRunning {
            Abrir()
        }
        Cancelar=false
        Reloj.Start()
        if !TareaActiva {
            Thread1 = Thread(target:self, selector:#selector(Tarea), object:nil)
            Thread1?.start()
        }
    }
    
    public func Parar() {
        var Contador:Int=0
        if AudioEngine.isRunning {
            //AudioEngine.stop()
            //Player.pause()
        }
        if TareaActiva {
            Cancelar = true
            repeat {
                Contador+=1
                usleep(1000)
            } while TareaActiva==true && Contador<1000

        }
        let nose=Thread1?.isExecuting
        Reproduciendo = false
        Reloj.Stop()
        TareaActiva = false
        Cancelar = false
    }
    
    public func Abrir() {
        WaveBuffer.Clear()
        do{
            try AudioEngine.start()
            Abierto = true

        } catch {
            Abierto = false
        }
    }
    
   public func Cerrar () {
       if Reproduciendo {
           Parar()
       }
       Abierto = false
   }
    
     func handler() -> Void
    {
        /*
        struct estatico {
            static var contador:UInt32=0
        }
        estatico.contador+=1
        print(estatico.contador)
        */
        
        if BufferDepleted {
            Player.pause()
            if TareaActiva {
                Cancelar = true
            }
            //Parar()
            print("Buffer Vacío")
            return
        }
        BufferDepleted=true
        

    }

    
    @objc func Tarea() {
        var Contador:Int=0
        var NumeroBytes:Int
        if Abierto==false { return }
        if !AudioEngine.isRunning { return }
        
        TareaActiva = true
        WaveBuffer.Clear()
        Mixer.outputVolume=1
        for Contador:Int in 0..<(2 * WAVE_BUFFER_SIZE) {
            WaveBuffer.Append(Value: Sonido!.Reproducir())
        }
        
        for i in 0..<Int(Buffer1.frameLength) {
            Buffer1.floatChannelData?.pointee[i] = WaveBuffer.Buffer[i]
        }
        for i in 0..<Int(Buffer2.frameLength) {
            Buffer2.floatChannelData?.pointee[i] = WaveBuffer.Buffer[i+WAVE_BUFFER_SIZE]
        }

        // play player and buffer

        
        BufferDepleted=false
        Estado=0
        Player.scheduleBuffer(Buffer1, at: nil, completionHandler: handler)
        Player.scheduleBuffer(Buffer2, at: nil, completionHandler: handler)
        Player.play()
        Reproduciendo = true
        Reloj.Start()
        usleep(1000)
        WaveBuffer.Clear()
        
        while true {
            /*
            if Mixer.outputVolume < 1.0 {
                if Mixer.outputVolume < 0.1 {
                    Mixer.outputVolume+=0.0001
                } else {
                    Mixer.outputVolume+=0.001
                }
                
            }*/
            NumeroBytes = Tics2Bytes(Tics: Reloj.EllapsedMicroseconds())
            /*
            for Contador:Int in 0..<(nose.count-1) {
                nose[Contador]=nose[Contador+1]
            }
            nose[nose.count-1]=Int(Reloj.EllapsedMicroseconds())
 */
            if NumeroBytes>0 {
                for _:Int in 1...NumeroBytes {
                    WaveBuffer.Append(Value: Sonido!.Reproducir())
                }
            }
            if BufferDepleted {
                Reloj.Start()

                while WaveBuffer.Pointer < WAVE_BUFFER_SIZE {
                    WaveBuffer.Append(Value: Sonido!.Reproducir())
                }
                if Estado==0 {
                    for i in 0..<Int(Buffer1.frameLength) {
                        chivato=1
                        Buffer1.floatChannelData?.pointee[i] = WaveBuffer.Buffer[i]
                        chivato=2
                    }
                    chivato=3
                    Player.scheduleBuffer(Buffer1, at: nil, completionHandler: handler)
                    chivato=4
                    Estado=1
                } else {
                    for i in 0..<Int(Buffer2.frameLength) {
                        chivato=5
                        Buffer2.floatChannelData?.pointee[i] = WaveBuffer.Buffer[i]
                        chivato=6
                    }
                    chivato=7
                    Player.scheduleBuffer(Buffer2, at: nil, completionHandler: handler)
                    chivato=8
                    Estado=0
                }
                WaveBuffer.Shift()
                BufferDepleted=false
            }

            if Cancelar || !AudioEngine.isRunning {
                chivato=9
                if AudioEngine.isRunning {
                    Player.pause()
                }
                chivato=10
                break
            }
            usleep(1000)
        }
        Player.reset()
        Reproduciendo = false
        Reloj.Stop()
        TareaActiva = false
        Cancelar = false
    }
    

    
    
    private func Tics2Bytes(Tics:UInt64) -> Int {
        var Tics2Bytes:Int = 0
        var BytesDouble:Float
        var BytesNumber:Int
        BytesDouble = Float(Tics) * BytesPorTic
        if WaveBuffer.IsFull {
            Tics2Bytes = 0
        } else {
            BytesNumber = Int(BytesDouble.rounded(.down)) - WaveBuffer.Pointer
            if BytesNumber > WaveBuffer.GetFreeSpace() {
                Tics2Bytes = WaveBuffer.GetFreeSpace()
            } else {
                Tics2Bytes = BytesNumber
            }
        }
        if Tics2Bytes<0 {
            Tics2Bytes=0
            //print("666")
        }
        return Tics2Bytes
    }


    

    
    
    
    
}
