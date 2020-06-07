//
//  cAY8912.swift
//  Abadia
//
//  Created by javier on 17/03/2020.
//  Copyright © 2020 javier abadía. All rights reserved.
//

import Foundation




class AY8912 : Reproducible {
    
    public let MAX_OUTPUT:Int = 63
    public let AY_STEP:Int = 32768
    public let MAXVOL:Int = 0x1F

    // AY register ID's
    public let AY_AFINE:Int = 0
    public let AY_ACOARSE:Int = 1
    public let AY_BFINE:Int = 2
    public let AY_BCOARSE:Int = 3
    public let AY_CFINE:Int = 4
    public let AY_CCOARSE:Int = 5
    public let AY_NOISEPER:Int = 6
    public let AY_ENABLE:Int = 7
    public let AY_AVOL:Int = 8
    public let AY_BVOL:Int = 9
    public let AY_CVOL:Int = 10
    public let AY_EFINE:Int = 11
    public let AY_ECOARSE:Int = 12
    public let AY_ESHAPE:Int = 13
    public let AY_PORTA:Int = 14
    public let AY_PORTB:Int = 15

    //AY-3-3912 con la frecuencia de un Amstrad
    public let PSG_FREQ:Double = 1000000

    struct AYPSG {
        static var sampleRate:Int=0
        static var register_latch:Int=0
        static var Regs:[Int]=[0]
        static var UpdateStep:Double=0
        static var PeriodA:Int=0
        static var PeriodB:Int=0
        static var PeriodC:Int=0
        static var PeriodN:Int=0
        static var PeriodE:Int=0
        static var CountA:Int=0
        static var CountB:Int=0
        static var CountC:Int=0
        static var CountN:Int=0
        static var CountE:Int=0
        static var VolA:Int=0
        static var VolB:Int=0
        static var VolC:Int=0
        static var VolE:Int=0
        static var EnvelopeA:Int=0
        static var EnvelopeB:Int=0
        static var EnvelopeC:Int=0
        static var OutputA:Int=0
        static var OutputB:Int=0
        static var OutputC:Int=0
        static var OutputN:Int=0
        static var CountEnv:Int=0
        static var Hold:Int=0
        static var Alternate:Int=0
        static var Attack:Int=0
        static var Holding:Int=0
        static var VolTable2:[Int]=[0]
    }
 
    public var AY_OutNoise:Int=0
    public var VolA:Int=0
    public var VolB:Int=0
    public var VolC:Int=0
    private var lOut1:Int=0
    private var lOut2:Int=0
    private var lOut3:Int=0
    public var AY_Left:Int=0
    public var AY_NextEvent:Int=0
    public var Buffer_Length:Int=0
    
    init (FMuestreo:Int) {
        //inicializa para la frecuencia de reloj y la frecuencia de muestreo
        AY8912_init(clock: PSG_FREQ, sample_rate: FMuestreo, sample_bits: 8)
    }
    
    func AY8912_reset() {
        //var i:Int

        AYPSG.register_latch = 0
        AYPSG.OutputA = 0
        AYPSG.OutputB = 0
        AYPSG.OutputC = 0
        AYPSG.OutputN = 0xFF
        AYPSG.PeriodA = 0
        AYPSG.PeriodB = 0
        AYPSG.PeriodC = 0
        AYPSG.PeriodN = 0
        AYPSG.PeriodE = 0
        AYPSG.CountA = 0
        AYPSG.CountB = 0
        AYPSG.CountC = 0
        AYPSG.CountN = 0
        AYPSG.CountE = 0
        AYPSG.VolA = 0
        AYPSG.VolB = 0
        AYPSG.VolC = 0
        AYPSG.VolE = 0
        AYPSG.EnvelopeA = 0
        AYPSG.EnvelopeB = 0
        AYPSG.EnvelopeC = 0
        AYPSG.CountEnv = 0
        AYPSG.Hold = 0
        AYPSG.Alternate = 0
        AYPSG.Holding = 0
        AYPSG.Attack = 0

        for i:Int in 0...AY_PORTA {
            AYWriteReg(r: i, v: 0)
        }
    }
    
    func AY8912_set_clock(clock:Double) {
        var t1:Double

        // Calculate the number of AY_STEPs which happen during one sample
        // at the given sample rate. No. of events = sample rate / (clock/8).
        // AY_STEP is a multiplier used to turn the fraction into a fixed point
        // number.
        t1 = Double(AY_STEP) * Double(AYPSG.sampleRate) * Double(8)

        AYPSG.UpdateStep = t1 / clock
    }

    // AY8912_set_volume()
    //
    // Initialize the volume table
    func AY8912InitVolumeTable() {
        // The following volume levels are taken from the sound.c & sound.h files
        // in the FUSE emulator (suitably rescaled to 00-3F from 0000-FFFF) and
        // apparently more accurately represent real volume levels as measured
        // from a 128K Spectrum than the original algorithm used in previous
        // versions of vbSpec.
        AYPSG.VolTable2[0] = 0 ; AYPSG.VolTable2[1] = 0 ; AYPSG.VolTable2[2] = 1 ; AYPSG.VolTable2[3] = 1
        AYPSG.VolTable2[4] = 1 ; AYPSG.VolTable2[5] = 1 ; AYPSG.VolTable2[6] = 2 ; AYPSG.VolTable2[7] = 2
        AYPSG.VolTable2[8] = 3 ; AYPSG.VolTable2[9] = 3 ; AYPSG.VolTable2[10] = 4 ; AYPSG.VolTable2[11] = 4
        AYPSG.VolTable2[12] = 5 ; AYPSG.VolTable2[13] = 5 ; AYPSG.VolTable2[14] = 9 ; AYPSG.VolTable2[15] = 9

        AYPSG.VolTable2[16] = 11 ; AYPSG.VolTable2[17] = 11 ; AYPSG.VolTable2[18] = 17 ; AYPSG.VolTable2[19] = 17
        AYPSG.VolTable2[20] = 23 ; AYPSG.VolTable2[21] = 23 ; AYPSG.VolTable2[22] = 29 ; AYPSG.VolTable2[23] = 29
        AYPSG.VolTable2[24] = 37 ; AYPSG.VolTable2[25] = 37 ; AYPSG.VolTable2[26] = 44 ; AYPSG.VolTable2[27] = 44
        AYPSG.VolTable2[28] = 54 ; AYPSG.VolTable2[29] = 54 ; AYPSG.VolTable2[30] = 63 ; AYPSG.VolTable2[31] = 63
    }
    
    func AYWriteReg(r:Int, v:Int) {
        var old:Int

        AYPSG.Regs[r] = v

        // A note about the period of tones, noise and envelope: for speed reasons,
        // we count down from the period to 0, but careful studies of the chip
        // output prove that it instead counts up from 0 until the counter becomes
        // greater or equal to the period. This is an important difference when the
        // program is rapidly changing the period to modulate the sound.
        // To compensate for the difference, when the period is changed we adjust
        // our internal counter.
        // Also, note that period = 0 is the same as period = 1. This is mentioned
        // in the YM2203 data sheets. However, this does NOT apply to the Envelope
        // period. In that case, period = 0 is half as period = 1.
        switch r {
        case AY_AFINE, AY_ACOARSE:
                AYPSG.Regs[AY_ACOARSE] = AYPSG.Regs[AY_ACOARSE] & 0xF
                old = AYPSG.PeriodA
                AYPSG.PeriodA = Int(Double((AYPSG.Regs[AY_AFINE] + (256 * AYPSG.Regs[AY_ACOARSE]))) * (AYPSG.UpdateStep))
                if (AYPSG.PeriodA == 0) { AYPSG.PeriodA = Int(AYPSG.UpdateStep) }
                AYPSG.CountA = AYPSG.CountA + (AYPSG.PeriodA - old)
                if (AYPSG.CountA <= 0) { AYPSG.CountA = 1 }
        case AY_BFINE, AY_BCOARSE:
                AYPSG.Regs[AY_BCOARSE] = AYPSG.Regs[AY_BCOARSE] & 0xF
                old = AYPSG.PeriodB
                AYPSG.PeriodB = Int(Double((AYPSG.Regs[AY_BFINE] + (256 * AYPSG.Regs[AY_BCOARSE]))) * (AYPSG.UpdateStep))
                if (AYPSG.PeriodB == 0) { AYPSG.PeriodB = Int(AYPSG.UpdateStep) }
                AYPSG.CountB = AYPSG.CountB + AYPSG.PeriodB - old
                if (AYPSG.CountB <= 0) { AYPSG.CountB = 1 }
        case AY_CFINE, AY_CCOARSE:
                AYPSG.Regs[AY_CCOARSE] = AYPSG.Regs[AY_CCOARSE] & 0xF
                old = AYPSG.PeriodC
                AYPSG.PeriodC = Int(Double((AYPSG.Regs[AY_CFINE] + (256 * AYPSG.Regs[AY_CCOARSE]))) * (AYPSG.UpdateStep))
                if (AYPSG.PeriodC == 0) { AYPSG.PeriodC = Int(AYPSG.UpdateStep) }
                AYPSG.CountC = AYPSG.CountC + (AYPSG.PeriodC - old)
                if (AYPSG.CountC <= 0) { AYPSG.CountC = 1 }
        case AY_NOISEPER:
                AYPSG.Regs[AY_NOISEPER] = AYPSG.Regs[AY_NOISEPER] & 0x1F
                old = AYPSG.PeriodN
                AYPSG.PeriodN = AYPSG.Regs[AY_NOISEPER] * Int(AYPSG.UpdateStep)
                if (AYPSG.PeriodN == 0) { AYPSG.PeriodN = Int(AYPSG.UpdateStep) }
                AYPSG.CountN = AYPSG.CountN + (AYPSG.PeriodN - old)
                if (AYPSG.CountN <= 0) { AYPSG.CountN = 1 }
        case AY_AVOL:
                AYPSG.Regs[AY_AVOL] = AYPSG.Regs[AY_AVOL] & 0x1F
                AYPSG.EnvelopeA = AYPSG.Regs[AY_AVOL] & 0x10
                if AYPSG.EnvelopeA != 0 {
                    AYPSG.VolA = AYPSG.VolE
                } else {
                    if AYPSG.Regs[AY_AVOL] != 0 {
                        AYPSG.VolA = AYPSG.VolTable2[AYPSG.Regs[AY_AVOL] * 2 + 1]
                    } else {
                        AYPSG.VolA = AYPSG.VolTable2[0]
                    }
                }
        case AY_BVOL:
                AYPSG.Regs[AY_BVOL] = AYPSG.Regs[AY_BVOL] & 0x1F
                AYPSG.EnvelopeB = AYPSG.Regs[AY_BVOL] & 0x10
                if AYPSG.EnvelopeB != 0 {
                    AYPSG.VolB = AYPSG.VolE
                } else {
                    if AYPSG.Regs[AY_BVOL] != 0 {
                        AYPSG.VolB = AYPSG.VolTable2[AYPSG.Regs[AY_BVOL] * 2 + 1]
                    } else {
                        AYPSG.VolB = AYPSG.VolTable2[0]
                    }
                }
        case AY_CVOL:
                AYPSG.Regs[AY_CVOL] = AYPSG.Regs[AY_CVOL] & 0x1F
                AYPSG.EnvelopeC = AYPSG.Regs[AY_CVOL] & 0x10
                if AYPSG.EnvelopeC != 0 {
                    AYPSG.VolC = AYPSG.VolE
                } else {
                    if AYPSG.Regs[AY_CVOL] != 0 {
                        AYPSG.VolC = AYPSG.VolTable2[AYPSG.Regs[AY_CVOL] * 2 + 1]
                    } else {
                        AYPSG.VolC = AYPSG.VolTable2[0]
                    }
                }
        case AY_EFINE, AY_ECOARSE:
                old = AYPSG.PeriodE
                AYPSG.PeriodE = ((AYPSG.Regs[AY_EFINE] + (256 * AYPSG.Regs[AY_ECOARSE]))) * Int(AYPSG.UpdateStep)
                if (AYPSG.PeriodE == 0) { AYPSG.PeriodE = Int(AYPSG.UpdateStep / 2) }
                AYPSG.CountE = AYPSG.CountE + (AYPSG.PeriodE - old)
                if (AYPSG.CountE <= 0) { AYPSG.CountE = 1 }
        case AY_ESHAPE:
                // envelope shapes:
                // C AtAlH
                // 0 0 x x  \___
                //
                // 0 1 x x  /___
                //
                // 1 0 0 0  \\\\
                //
                // 1 0 0 1  \___
                //
                // 1 0 1 0  \/\/
                //          ___
                // 1 0 1 1  \
                //
                // 1 1 0 0  ////
                //           ___
                // 1 1 0 1  /
                //
                // 1 1 1 0  /\/\
                //
                // 1 1 1 1  /___
                //
                // The envelope counter on the AY-3-8910 has 16 AY_STEPs. On the YM2149 it
                // has twice the AY_STEPs, happening twice as fast. Since the end result is
                // just a smoother curve, we always use the YM2149 behaviour.
                if (AYPSG.Regs[AY_ESHAPE] != 0xFF) {
                    AYPSG.Regs[AY_ESHAPE] = AYPSG.Regs[AY_ESHAPE] & 0xF
                    if ((AYPSG.Regs[AY_ESHAPE] & 0x4) == 0x4) {
                        AYPSG.Attack = MAXVOL
                    } else {
                        AYPSG.Attack = 0x0
                    }

                    AYPSG.Hold = AYPSG.Regs[AY_ESHAPE] & 0x1
                    AYPSG.Alternate = AYPSG.Regs[AY_ESHAPE] & 0x2

                    AYPSG.CountE = AYPSG.PeriodE

                    AYPSG.CountEnv = MAXVOL // 0x1f
                    AYPSG.Holding = 0
                    AYPSG.VolE = AYPSG.VolTable2[AYPSG.CountEnv ^ AYPSG.Attack]
                    if (AYPSG.EnvelopeA != 0) { AYPSG.VolA = AYPSG.VolE }
                    if (AYPSG.EnvelopeB != 0) { AYPSG.VolB = AYPSG.VolE }
                    if (AYPSG.EnvelopeC != 0) { AYPSG.VolC = AYPSG.VolE }
                }
        default:
            //do nothing
            _=true
        }
    }
    
    func AY8912_init(clock:Double, sample_rate:Int, sample_bits:Int) -> Int {
        var AY8912_init:Int=0
        AYPSG.Regs=[Int](repeating:0, count:16)
        AYPSG.VolTable2=[Int](repeating:0, count:64)
        AYPSG.sampleRate = sample_rate

        AY8912_set_clock(clock: clock)
        AY8912InitVolumeTable()
        AY8912_reset()

        AY8912_init = 0
        return AY8912_init
    }
    
    func AY8912Update_8() {
        var Buffer_Length:Int

        Buffer_Length = 400

        // The 8910 has three outputs, each output is the mix of one of the three
        // tone generators and of the (single) noise generator. The two are mixed
        // BEFORE going into the DAC. The formula to mix each channel is:
        // (ToneOn | ToneDisable) & (NoiseOn | NoiseDisable).
        // Note that this means that if both tone and noise are disabled, the output
        // is 1, not 0, and can be modulated changing the volume.

        // If the channels are disabled, set their output to 1, and increase the
        // counter, if necessary, so they will not be inverted during this update.
        // Setting the output to 1 is necessary because a disabled channel is locked
        // into the ON state (see above); and it has no effect if the volume is 0.
        // If the volume is 0, increase the counter, but don't touch the output.
        if (AYPSG.Regs[AY_ENABLE] & 0x1) == 0x1 {
            if AYPSG.CountA <= (Buffer_Length * AY_STEP) { AYPSG.CountA = AYPSG.CountA + (Buffer_Length * AY_STEP) }
            AYPSG.OutputA = 1
        } else if (AYPSG.Regs[AY_AVOL] == 0) {
            // note that I do count += Buffer_Length, NOT count = Buffer_Length + 1. You might think
            // it's the same since the volume is 0, but doing the latter could cause
            // interference when the program is rapidly modulating the volume.
            if AYPSG.CountA <= (Buffer_Length * AY_STEP) { AYPSG.CountA = AYPSG.CountA + (Buffer_Length * AY_STEP) }
        }

        if (AYPSG.Regs[AY_ENABLE] & 0x2) == 0x2 {
            if AYPSG.CountB <= (Buffer_Length * AY_STEP) { AYPSG.CountB = AYPSG.CountB + (Buffer_Length * AY_STEP) }
            AYPSG.OutputB = 1
        } else if AYPSG.Regs[AY_BVOL] == 0 {
            if AYPSG.CountB <= (Buffer_Length * AY_STEP) { AYPSG.CountB = AYPSG.CountB + (Buffer_Length * AY_STEP) }
        }

        if (AYPSG.Regs[AY_ENABLE] & 0x4) == 0x4 {
            if AYPSG.CountC <= (Buffer_Length * AY_STEP) { AYPSG.CountC = AYPSG.CountC + (Buffer_Length * AY_STEP) }
            AYPSG.OutputC = 1
        } else if (AYPSG.Regs[AY_CVOL] == 0) {
            if AYPSG.CountC <= (Buffer_Length * AY_STEP) { AYPSG.CountC = AYPSG.CountC + (Buffer_Length * AY_STEP) }
        }

        // for the noise channel we must not touch OutputN - it's also not necessary
        //since we use AY_OutNoise.
        if ((AYPSG.Regs[AY_ENABLE] & 0x38) == 0x38) { // all off
            if AYPSG.CountN <= (Buffer_Length * AY_STEP) { AYPSG.CountN = AYPSG.CountN + (Buffer_Length * AY_STEP) }
        }

        AY_OutNoise = (AYPSG.OutputN | AYPSG.Regs[AY_ENABLE])
    }
    
    func RenderByte() -> Int {
        var RenderByte:Int = 0
        VolA = 0 ; VolB = 0 ; VolC = 0

        // VolA, VolB and VolC keep track of how integer each square wave stays
        // in the 1 position during the sample period.

        AY_Left = AY_STEP

        repeat {
            AY_NextEvent = 0

            if (AYPSG.CountN < AY_Left) {
                AY_NextEvent = AYPSG.CountN
            } else {
                AY_NextEvent = AY_Left
            }

            if (AY_OutNoise & 0x8) == 0x8 {
                if (AYPSG.OutputA == 1) { VolA = VolA + AYPSG.CountA }
                AYPSG.CountA = AYPSG.CountA - AY_NextEvent
                // PeriodA is the half period of the square wave. Here, in each
                // loop I add PeriodA twice, so that at the end of the loop the
                // square wave is in the same status (0 or 1) it was at the start.
                // vola is also incremented by PeriodA, since the wave has been 1
                // exactly half of the time, regardless of the initial position.
                // If we exit the loop in the middle, OutputA has to be inverted
                // and vola incremented only if the exit status of the square
                // wave is 1.

                while (AYPSG.CountA <= 0) {
                    AYPSG.CountA = AYPSG.CountA + AYPSG.PeriodA
                    if (AYPSG.CountA > 0) {
                        if (AYPSG.Regs[AY_ENABLE] & 1) == 0 { AYPSG.OutputA = AYPSG.OutputA ^ 1 }
                        if (AYPSG.OutputA != 0) { VolA = VolA + AYPSG.PeriodA }
                        break
                    }
                    AYPSG.CountA = AYPSG.CountA + AYPSG.PeriodA
                    VolA = VolA + AYPSG.PeriodA
                }
                if (AYPSG.OutputA == 1) { VolA = VolA - AYPSG.CountA }
            } else {
                AYPSG.CountA = AYPSG.CountA - AY_NextEvent
                while (AYPSG.CountA <= 0) {
                    AYPSG.CountA = AYPSG.CountA + AYPSG.PeriodA
                    if (AYPSG.CountA > 0) {
                        AYPSG.OutputA = AYPSG.OutputA ^ 1
                        break
                    }
                    AYPSG.CountA = AYPSG.CountA + AYPSG.PeriodA
                }
            }

            if (AY_OutNoise & 0x10) == 0x10 {
                if (AYPSG.OutputB == 1) { VolB = VolB + AYPSG.CountB }
                AYPSG.CountB = AYPSG.CountB - AY_NextEvent
                while (AYPSG.CountB <= 0) {
                    AYPSG.CountB = AYPSG.CountB + AYPSG.PeriodB
                    if (AYPSG.CountB > 0) {
                        if (AYPSG.Regs[AY_ENABLE] & 2) == 0 { AYPSG.OutputB = AYPSG.OutputB ^ 1 }
                        if (AYPSG.OutputB != 0) { VolB = VolB + AYPSG.PeriodB }
                        break
                    }
                    AYPSG.CountB = AYPSG.CountB + AYPSG.PeriodB
                    VolB = VolB + AYPSG.PeriodB
                }
                if (AYPSG.OutputB == 1) { VolB = VolB - AYPSG.CountB }
            } else {
                AYPSG.CountB = AYPSG.CountB - AY_NextEvent
                while (AYPSG.CountB <= 0) {
                    AYPSG.CountB = AYPSG.CountB + AYPSG.PeriodB
                    if (AYPSG.CountB > 0) {
                        AYPSG.OutputB = AYPSG.OutputB ^ 1
                        break
                    }
                    AYPSG.CountB = AYPSG.CountB + AYPSG.PeriodB
                }
            }

            if (AY_OutNoise & 0x20) == 0x20 {
                if (AYPSG.OutputC == 1) { VolC = VolC + AYPSG.CountC }
                AYPSG.CountC = AYPSG.CountC - AY_NextEvent
                while (AYPSG.CountC <= 0) {
                    AYPSG.CountC = AYPSG.CountC + AYPSG.PeriodC
                    if (AYPSG.CountC > 0) {
                        if (AYPSG.Regs[AY_ENABLE] & 4) == 0 { AYPSG.OutputC = AYPSG.OutputC ^ 1 }
                        if (AYPSG.OutputC != 0) { VolC = VolC + AYPSG.PeriodC }
                        break
                    }
                    AYPSG.CountC = AYPSG.CountC + AYPSG.PeriodC
                    VolC = VolC + AYPSG.PeriodC
                }
                if (AYPSG.OutputC == 1) { VolC = VolC - AYPSG.CountC }
            } else {
                AYPSG.CountC = AYPSG.CountC - AY_NextEvent
                while (AYPSG.CountC <= 0) {
                    AYPSG.CountC = AYPSG.CountC + AYPSG.PeriodC
                    if (AYPSG.CountC > 0) {
                        AYPSG.OutputC = AYPSG.OutputC ^ 1
                        break
                    }
                    AYPSG.CountC = AYPSG.CountC + AYPSG.PeriodC
                }
            }

            AYPSG.CountN = AYPSG.CountN - AY_NextEvent
            if (AYPSG.CountN <= 0) {
                // Is noise output going to change?
                //AYPSG.OutputN = Int(Rnd(1) * 2) * 255
                AYPSG.OutputN = Int(round(Float.random(in: 0...1) * 2)) * 255
                AY_OutNoise = (AYPSG.OutputN | AYPSG.Regs[AY_ENABLE])

                AYPSG.CountN = AYPSG.CountN + AYPSG.PeriodN
            }

            AY_Left = AY_Left - AY_NextEvent
        } while (AY_Left > 0)

        if (AYPSG.Holding == 0) {
            AYPSG.CountE = AYPSG.CountE - AY_STEP
            if (AYPSG.CountE <= 0) {
                repeat {
                    AYPSG.CountEnv = AYPSG.CountEnv - 1
                    AYPSG.CountE = AYPSG.CountE + AYPSG.PeriodE
                } while (AYPSG.CountE <= 0)

                // check envelope current position
                if (AYPSG.CountEnv < 0) {
                    if (AYPSG.Hold != 0) {
                        if (AYPSG.Alternate != 0) {
                            AYPSG.Attack = AYPSG.Attack ^ MAXVOL //0x1f
                        }
                        AYPSG.Holding = 1
                        AYPSG.CountEnv = 0
                    } else {
                        // if CountEnv has looped an odd number of times (usually 1),
                        // invert the output.
                        if ((AYPSG.Alternate != 0) && ((AYPSG.CountEnv & 0x20) == 0x20)) {
                            AYPSG.Attack = AYPSG.Attack ^ MAXVOL // 0x1f
                        }

                        AYPSG.CountEnv = AYPSG.CountEnv & MAXVOL // 0x1f
                    }
                }

                AYPSG.VolE = AYPSG.VolTable2[AYPSG.CountEnv ^ AYPSG.Attack]
                // reload volume
                if (AYPSG.EnvelopeA != 0) { AYPSG.VolA = AYPSG.VolE }
                if (AYPSG.EnvelopeB != 0) { AYPSG.VolB = AYPSG.VolE }
                if (AYPSG.EnvelopeC != 0) { AYPSG.VolC = AYPSG.VolE }
            }
        }

        lOut1 = (VolA * AYPSG.VolA) / 65535
        lOut2 = (VolB * AYPSG.VolB) / 65535
        lOut3 = (VolC * AYPSG.VolC) / 65535

        RenderByte = lOut1 + lOut2 + lOut3
        return RenderByte
    }
    func GetPSGWave() -> UInt8 {
        struct Estatico {
            static var WCount:Int=0
        }
        var PSG:Int
        Estatico.WCount = Estatico.WCount + 1
        if Estatico.WCount == 800 {
            AY8912Update_8()
            Estatico.WCount = 0
        }
        PSG = RenderByte()
        if PSG > 255 { PSG = 255 }
        if PSG < 0 { PSG = 0 }
        return UInt8(PSG)
    }
    
    func EscribirRegistro(NumeroRegistro:Int, ValorRegistro:Int) {
        AYWriteReg(r: NumeroRegistro, v: ValorRegistro)
    }
    
    func Reproducir() -> Float {
        return Float(GetPSGWave())/256
    }
}
