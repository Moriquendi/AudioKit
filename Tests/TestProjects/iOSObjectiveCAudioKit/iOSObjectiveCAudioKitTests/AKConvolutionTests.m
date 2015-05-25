//
//  AKConvolutionTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "AKFoundation.h"
#import "NSData+MD5.h"

#define testDuration 10.0

@interface TestConvolutionInstrument : AKInstrument
@end

@implementation TestConvolutionInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        NSString *filename = [AKManager pathToSoundFile:@"808loop" ofType:@"wav"];
        AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
        audio.loop = YES;
        AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];
        
        AKLine *mixLine = [[AKLine alloc] initWithFirstPoint:akp(0)
                                                 secondPoint:akp(1)
                                       durationBetweenPoints:akp(testDuration)];
        NSString *dishFilename      = [AKManager pathToSoundFile:@"dish"      ofType:@"wav"];
        NSString *stairwellFilename = [AKManager pathToSoundFile:@"Stairwell" ofType:@"wav"];
        
        AKConvolution *dishConvolution      = [[AKConvolution alloc] initWithInput:mono impulseResponseFilename:dishFilename];
        AKConvolution *stairwellConvolution = [[AKConvolution alloc] initWithInput:mono impulseResponseFilename:stairwellFilename];
        
        AKMix *dishMix      = [[AKMix alloc] initWithInput1:mono input2:dishConvolution      balance:akp(0.2)];
        AKMix *stairwellMix = [[AKMix alloc] initWithInput1:mono input2:stairwellConvolution balance:akp(0.2)];
        
        AKMix *mix = [[AKMix alloc] initWithInput1:dishMix input2:stairwellMix balance:mixLine];
        
        [self setAudioOutput:[mix scaledBy:akp(0.1)]];
    }
    return self;
}

@end

@interface AKConvolutionTests : XCTestCase
@end

@implementation AKConvolutionTests

- (void)testConvolution
{
    // Set up performance
    TestConvolutionInstrument *testInstrument = [[TestConvolutionInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];
    
    // Render audio output
    NSString *outputFile = [NSString stringWithFormat:@"%@/AKTest-Convolution.aiff", NSTemporaryDirectory()];
    [[AKManager sharedManager] renderToFile:outputFile forDuration:testDuration];
    
    // Check output
    NSData *nsData = [NSData dataWithContentsOfFile:outputFile];
    XCTAssertEqualObjects([nsData MD5], @"ec2562141e910c1c87163b5430d591fd");
}

@end
