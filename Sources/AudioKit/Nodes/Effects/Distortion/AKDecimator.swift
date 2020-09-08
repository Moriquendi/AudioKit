// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
// This file was auto-autogenerated by scripts and templates at http://github.com/AudioKit/AudioKitDevTools/

import AVFoundation

/// AudioKit version of Apple's Decimator Audio Unit
///
open class AKDecimator: AKNode, AKToggleable {

    fileprivate let effectAU = AVAudioUnitEffect(
    audioComponentDescription:
    AudioComponentDescription(appleEffect: kAudioUnitSubType_Distortion))

    /// Decimation (Percent) ranges from 0 to 100 (Default: 50)
    @Parameter public var decimation: AUValue

    /// Rounding (Percent) ranges from 0 to 100 (Default: 0)
    @Parameter public var rounding: AUValue

    /// Final Mix (Percent) ranges from 0 to 100 (Default: 50)
    @Parameter public var finalMix: AUValue

    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted = true

    /// Initialize the decimator node
    ///
    /// - parameter input: Input node to process
    /// - parameter decimation: Decimation (Percent) ranges from 0 to 100 (Default: 50)
    /// - parameter rounding: Rounding (Percent) ranges from 0 to 100 (Default: 0)
    /// - parameter finalMix: Final Mix (Percent) ranges from 0 to 100 (Default: 50)
    ///
    public init(
        _ input: AKNode,
        decimation: AUValue = 50,
        rounding: AUValue = 0,
        finalMix: AUValue = 50) {
        super.init(avAudioNode: effectAU)
        connections.append(input)

        self.$decimation.associate(with: effectAU, index: 7)
        self.$rounding.associate(with: effectAU, index: 8)
        self.$finalMix.associate(with: effectAU, index: 15)

        self.decimation = decimation
        self.rounding = rounding
        self.finalMix = finalMix
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