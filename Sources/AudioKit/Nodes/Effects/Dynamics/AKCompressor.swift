// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
// This file was auto-autogenerated by scripts and templates at http://github.com/AudioKit/AudioKitDevTools/

import AVFoundation

/// AudioKit version of Apple's DynamicsProcessor Audio Unit's Compression Parts
///
open class AKCompressor: AKNode, AKToggleable {

    fileprivate let effectAU = AVAudioUnitEffect(
    audioComponentDescription:
    AudioComponentDescription(appleEffect: kAudioUnitSubType_DynamicsProcessor))

    /// Threshold (dB) ranges from -40 to 20 (Default: -20)
    @Parameter public var threshold: AUValue

    /// Head Room (dB) ranges from 0.1 to 40.0 (Default: 5)
    @Parameter public var headRoom: AUValue

    /// Attack Time (secs) ranges from 0.0001 to 0.2 (Default: 0.001)
    @Parameter public var attackTime: AUValue

    /// Release Time (secs) ranges from 0.01 to 3 (Default: 0.05)
    @Parameter public var releaseTime: AUValue

    /// Master Gain (dB) ranges from -40 to 40 (Default: 0)
    @Parameter public var masterGain: AUValue

    /// Compression Amount (dB) read only
    public var compressionAmount: AUValue {
        return effectAU.auAudioUnit.parameterTree?.allParameters[7].value ?? 0
    }

    /// Input Amplitude (dB) read only
    public var inputAmplitude: AUValue {
        return effectAU.auAudioUnit.parameterTree?.allParameters[8].value ?? 0
    }

    /// Output Amplitude (dB) read only
    public var outputAmplitude: AUValue {
        return effectAU.auAudioUnit.parameterTree?.allParameters[9].value ?? 0
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted = true

    /// Initialize the dynamics processor node
    ///
    /// - parameter input: Input node to process
    /// - parameter threshold: Threshold (dB) ranges from -40 to 20 (Default: -20)
    /// - parameter headRoom: Head Room (dB) ranges from 0.1 to 40.0 (Default: 5)
    /// - parameter attackTime: Attack Time (secs) ranges from 0.0001 to 0.2 (Default: 0.001)
    /// - parameter releaseTime: Release Time (secs) ranges from 0.01 to 3 (Default: 0.05)
    /// - parameter masterGain: Master Gain (dB) ranges from -40 to 40 (Default: 0)
    ///
    public init(
        _ input: AKNode,
        threshold: AUValue = -20,
        headRoom: AUValue = 5,
        attackTime: AUValue = 0.001,
        releaseTime: AUValue = 0.05,
        masterGain: AUValue = 0) {

        super.init(avAudioNode: effectAU)
        connections.append(input)

        self.$threshold.associate(with: effectAU, index: 0)
        self.$headRoom.associate(with: effectAU, index: 1)
        self.$attackTime.associate(with: effectAU, index: 4)
        self.$releaseTime.associate(with: effectAU, index: 5)
        self.$masterGain.associate(with: effectAU, index: 6)

        self.threshold = threshold
        self.headRoom = headRoom
        self.attackTime = attackTime
        self.releaseTime = releaseTime
        self.masterGain = masterGain
    }

    /// Function to start, play, or activate the node, all do the same thing
    public func start() {
        effectAU.bypass = false
        isStarted = true
    }

    /// Function to stop or bypass the node, both are equivalent
    public func stop() {
        effectAU.bypass = true
        isStarted = false
    }
}