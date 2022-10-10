//
//  ToneGenerator.swift
//  ToneGeneratorSwift
//
//  Created by Andy Cho on 10/10/22.
//

import AudioUnit
import AVFoundation

class ToneGenerator {
    private static let BytesPerFloat: UInt32 = 4
    private static let BitsPerByte: UInt32 = 8
    private static let SampleRate: Double = 44100
    private static let Amplitude: Double = 0.25
    private static let MonotoneChannel = 0

    private var audioComponentInstance: AudioComponentInstance?
    private var theta: Double = 0

    // MARK: Public APIs

    public var frequency: Double = 0

    /**
     * Play a frequency given a value between 0 and 1
     */

    func play() {
        if audioComponentInstance == nil {
            audioComponentInstance = createAudioUnit()
            guard let audioComponentInstance else {
                print("Audio component could not be created")
                return
            }

            // This starts the sound
            AudioUnitInitialize(audioComponentInstance)
            AudioOutputUnitStart(audioComponentInstance)
        }
    }

    func stop() {
        guard let audioComponentInstance else {
            return
        }
        AudioOutputUnitStop(audioComponentInstance)
        AudioUnitUninitialize(audioComponentInstance)
        AudioComponentInstanceDispose(audioComponentInstance)
        self.audioComponentInstance = nil
    }

    // MARK: Private helpers

    private static func RenderToneCallback(inRefCon: UnsafeMutableRawPointer, ioActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>, inTimeStamp: UnsafePointer<AudioTimeStamp>, inBusNumber: UInt32, inNumberFrames: UInt32, ioData: UnsafeMutablePointer<AudioBufferList>?) -> OSStatus {
        let toneGenerator = unsafeBitCast(inRefCon, to: ToneGenerator.self)
        var theta = toneGenerator.theta
        let thetaIncrement = 2.0 * Double.pi * toneGenerator.frequency / ToneGenerator.SampleRate

        guard let ioPtr = UnsafeMutableAudioBufferListPointer(ioData),
              let monotoneChannel = ioPtr[ToneGenerator.MonotoneChannel].mData else {
            fatalError("Could not access the monotone channel in the passed in buffer")
        }
        let buffer = monotoneChannel.assumingMemoryBound(to: Float.self)

        // Generate the samples
        for frame in 0 ..< inNumberFrames {
            buffer[Int(frame)] = Float(sin(theta) * ToneGenerator.Amplitude)
            theta += thetaIncrement
            if theta > 2.0 * Double.pi {
                theta -= 2.0 * Double.pi
            }
        }

        // Store the updated theta
        toneGenerator.theta = theta

        return noErr
    }

    private func createAudioUnit() -> AudioComponentInstance? {
        // Find the default playback output unit
        var audioComponentDescription = AudioComponentDescription(componentType: kAudioUnitType_Output,
                                                                  componentSubType: kAudioUnitSubType_RemoteIO,
                                                                  componentManufacturer: kAudioUnitManufacturer_Apple,
                                                                  componentFlags: 0,
                                                                  componentFlagsMask: 0)

        // Get the default playback unit
        guard let defaultOutput = AudioComponentFindNext(nil, &audioComponentDescription) else {
            fatalError("Can't find default output")
        }

        // Create the audio component instance using the output
        var toneUnit: AudioComponentInstance?
        guard AudioComponentInstanceNew(defaultOutput, &toneUnit) == noErr, let toneUnit else {
            fatalError("Could not create AudioComponentInstance")
        }

        // Set the tone rendering function
        var renderCallback = AURenderCallbackStruct(inputProc: { (inRefCon, ioActionFlags, inTimeStamp, inBusNumber, inNumberFrames, ioData) -> OSStatus in
            return ToneGenerator.RenderToneCallback(inRefCon: inRefCon, ioActionFlags: ioActionFlags, inTimeStamp: inTimeStamp, inBusNumber: inBusNumber, inNumberFrames: inNumberFrames, ioData: ioData)
        }, inputProcRefCon: Unmanaged.passUnretained(self).toOpaque())

        // Set the callback
        if AudioUnitSetProperty(toneUnit, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input, 0 /* inElement */, &renderCallback, UInt32(MemoryLayout.size(ofValue: renderCallback))) != noErr {
            fatalError("Could not set the callback")
        }

        // Magic settings from Matt Gallagher
        // Apparently sets to: 32bit, single channel, floating point, linear PCM
        var streamFormat = AudioStreamBasicDescription()
        streamFormat.mSampleRate = ToneGenerator.SampleRate
        streamFormat.mFormatID = kAudioFormatLinearPCM
        streamFormat.mFormatFlags = kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved
        streamFormat.mBytesPerPacket = ToneGenerator.BytesPerFloat
        streamFormat.mFramesPerPacket = 1
        streamFormat.mBytesPerFrame = ToneGenerator.BytesPerFloat
        streamFormat.mChannelsPerFrame = 1
        streamFormat.mBitsPerChannel = ToneGenerator.BytesPerFloat * ToneGenerator.BitsPerByte

        if AudioUnitSetProperty(toneUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0 /* inElement */, &streamFormat, UInt32(MemoryLayout.size(ofValue: streamFormat))) != noErr {
            fatalError("Could not set the audio stream format")
        }

        return toneUnit
    }
}
