//
//  Sound.swift
//  
//
//  Created by Илья Михальцов on 10/25/14.
//
//

import Cocoa
import AVFoundation

let F = 8192
let M = F / 4
let MBin = 2048

let engine = AVAudioEngine()

let player = AVAudioPlayerNode()

let format = AVAudioFormat(standardFormatWithSampleRate: Double(F), channels: 1)

engine.attachNode(player)
engine.connect(player, to: engine.mainMixerNode, format:format)

let frameCapacity: UInt32 = 8192


let error: NSErrorPointer = nil
if engine.startAndReturnError(error) {
    println("Engine initialized successfully")
}



let waveform = { (i: Int) -> UInt8 in
    var n: UInt8 = 0
    var s: UInt8 = 0

    if i | MBin != i {
        // beat
        if (i % MBin) < 257 {
            n = UInt8(truncatingBitPattern: 256 - i % MBin)
        }
    }

    s = 0;
    switch (3) {
    case -1:
        s = (i%50) < 25 ? 127 : 0
    case 0:
        s = s &+ UInt8(truncatingBitPattern: abs((i&127) - 63) << 2)
        break
    case 1:
        s = s &+ UInt8(i & 127)
        break
    case 2:
        s = s &+ UInt8(i & 16)
        break
    case 3:
        s = s &+ UInt8(127.5 * (1.0+sin(2.0 * Float(M_PI) * Float(i) / 50)))
        break
    default:
        break
    }
//    s = UInt8(truncatingBitPattern: i & 48 & (i >> 8))
//    s = UInt8(truncatingBitPattern: 224 & (i*3) & i >> 8)
//    s = UInt8(truncatingBitPattern: 224 & (i * 3) & Int(b) & (i >> 9))
//    if (i & 1535) == 0 {
//        b = b << 1;
//        b |= 1 & (b >> 7 ^ b >> 5 ^ b >> 4 ^ b >> 3 ^ 1);
//    }
    // s = (i*3)&128;
    // s = i*(i & 146);
//    let t = UInt16(s/3) + UInt16(n)
//    s = t > UInt16(UInt8.max) ? UInt8.max : UInt8(t)

//    let t1 = (i/Int(1e7))*i*i+i%127
//    let t2 = i%127+(i>>16)
//    s = UInt8(truncatingBitPattern: t1|(i>>4)|(i>>5)|t2|i)

    return s
}

var iOffset = 0


let fillBuffer = { (buffer: AVAudioPCMBuffer) -> Void in
    for i in iOffset..<iOffset+Int(frameCapacity) {
        let u = Float(waveform(i)) / 256.0
        buffer.floatChannelData.memory[i - iOffset] = u
    }
    iOffset += Int(frameCapacity)
    println("Frame filled. Current offset: \(iOffset)")
}


let queue = NSOperationQueue()


func completionHandler(oldBuffer: AVAudioPCMBuffer) -> (() -> Void) { return { () -> Void in

    let buffer = AVAudioPCMBuffer(PCMFormat: format, frameCapacity: frameCapacity)
    buffer.frameLength = frameCapacity

    queue.addOperationWithBlock {
        fillBuffer(buffer)
    }

    player.scheduleBuffer(oldBuffer, atTime: nil, options: .InterruptsAtLoop, completionHandler: completionHandler(buffer))
}}


let buffer = AVAudioPCMBuffer(PCMFormat: format, frameCapacity: frameCapacity)
buffer.frameLength = frameCapacity
fillBuffer(buffer)

completionHandler(buffer)()

player.play()

println("Started playing...")

while true {
    sleep(100)
}

