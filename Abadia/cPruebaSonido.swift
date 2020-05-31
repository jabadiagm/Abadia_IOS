//
//  cPruebaSonido.swift
//  Abadia
//
//  Created by javier on 21/03/2020.
//  Copyright © 2020 Phillip LAcebo. All rights reserved.
//

import Foundation
import AVFoundation

class cPruebaSonido {
    var ae:AVAudioEngine?
    var player:AVAudioPlayerNode?
    var mixer:AVAudioMixerNode?
    var buffer:AVAudioPCMBuffer?
    
    public func Reproducir() {
        ae = AVAudioEngine()
        player = AVAudioPlayerNode()
        mixer = ae?.mainMixerNode;
        buffer = AVAudioPCMBuffer(pcmFormat: (player?.outputFormat(forBus: 0))!, frameCapacity: 100)
        buffer?.frameLength = 100
        
        // generate sine wave
        let sr:Float = Float((mixer?.outputFormat(forBus: 0).sampleRate)!)
        let n_channels = mixer?.outputFormat(forBus: 0).channelCount

        for i in stride(from:0, to: Int((buffer?.frameLength)!), by: Int(n_channels!)) {
            let val = sinf(441.0*Float(i)*2*Float(Double.pi)/sr)
            buffer?.floatChannelData?.pointee[i] = val * 0.5
        }
        
        // setup audio engine
        ae?.attach(player!)
        ae?.connect(player!, to: mixer!, format: player?.outputFormat(forBus: 0))
        do{
            try ae?.start()
        } catch {
        
        }
        
        
        // play player and buffer
        player?.play()
        player?.scheduleBuffer(buffer!, at: nil, options: .loops, completionHandler: nil)
        
    }
}
