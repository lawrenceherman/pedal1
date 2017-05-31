//
//  PedalAUAudioUnit.m
//  PedalAU
//
//  Created by Lawrence Herman on 5/25/17.
//  Copyright © 2017 Lawrence Herman. All rights reserved.
//

#import "PedalAUAudioUnit.h"

#import <AVFoundation/AVFoundation.h>
//#import "BufferedAudioBus.hpp"

// Define parameter addresses.
const AudioUnitParameterID myParam1 = 0;
//const AudioUnitParameterID myParam2 = 0;

// filter sets up presets here

@interface PedalAUAudioUnit ()

@property (nonatomic, readwrite) AUParameterTree *parameterTree;

// ADDED  // check out why no input bus in filter --uses BufferedAudioBusC++ Clas

@property AUAudioUnitBus *outputBus;
@property AUAudioUnitBus *inputBus;
@property AUAudioUnitBusArray *inputBusArray;
@property AUAudioUnitBusArray *outputBusArray;

@end

// TO HERE



@implementation PedalAUAudioUnit
@synthesize parameterTree = _parameterTree;

- (instancetype)initWithComponentDescription:(AudioComponentDescription)componentDescription options:(AudioComponentInstantiationOptions)options error:(NSError **)outError {
    self = [super initWithComponentDescription:componentDescription options:options error:outError];
    
    if (self == nil) {
        return nil;
    }
    
    // initialize a default format for the busses.  ------ ADDED
    AVAudioFormat *defaultFormat = [[AVAudioFormat alloc] initStandardFormatWithSampleRate:44100.0 channels:2];
    
    
    // create a DSP Kernal to handle the signal processing? from filter"
    
    // Create parameter objects.  checkout need for flags
    AUParameter *param1 = [AUParameterTree createParameterWithIdentifier:@"param1" name:@"Parameter 1" address:myParam1 min:0 max:100 unit:kAudioUnitParameterUnit_Percent unitName:nil flags:0 valueStrings:nil dependentParameters:nil];
//    
//    AUParameter *param2 = [AUParameterTree createParameterWithIdentifier:@"param2" name:@"Parameter 2" address:myParam2 min:0 max:100 unit:kAudioUnitParameterUnit_Percent unitName:nil flags:0 valueStrings:nil dependentParameters:nil];
    
    // Initialize the parameter values.
    param1.value = 0.5;
//    param2.value = 0.5;
    
    // kernal work here in filter
    
    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[ param1 ]];
    
    // Create the input and output busses (AUAudioUnitBus).
    
    // ADDED
    
    
    _inputBus = [[AUAudioUnitBus alloc] initWithFormat:defaultFormat error:nil];
    
    
    _outputBus = [[AUAudioUnitBus alloc] initWithFormat:defaultFormat error:nil];
    
    
    
    // Create the input and output bus arrays (AUAudioUnitBusArray).
    
    // ADDED --- one change no .bus on end of _inputBus
    
    _inputBusArray = [[AUAudioUnitBusArray alloc] initWithAudioUnit:self busType:AUAudioUnitBusTypeInput busses: @[_inputBus]];
    
    _outputBusArray = [[AUAudioUnitBusArray alloc] initWithAudioUnit:self busType:AUAudioUnitBusTypeOutput busses: @[_outputBus]];
    
    
    // A function to provide string representations of parameter values.
    _parameterTree.implementorStringFromValueCallback = ^(AUParameter *param, const AUValue *__nullable valuePtr) {
        AUValue value = valuePtr == nil ? param.value : *valuePtr;
        
        switch (param.address) {
            case myParam1:
                return [NSString stringWithFormat:@"%.f", value];
            default:
                return @"?";
        }
    };
    
    self.maximumFramesToRender = 512;
    
    return self;
}


#pragma mark - AUAudioUnit Overrides

// If an audio unit has input, an audio unit's audio input connection points.
// Subclassers must override this property getter and should return the same object every time.
// See sample code.

// CHANGED ---------- originally returned nil

- (AUAudioUnitBusArray *)inputBusses {
    return _inputBusArray;
}

// An audio unit's audio output connection points.
// Subclassers must override this property getter and should return the same object every time.
// See sample code.
- (AUAudioUnitBusArray *)outputBusses {
    return _outputBusArray;
}

// Allocate resources required to render.
// Subclassers should call the superclass implementation.
- (BOOL)allocateRenderResourcesAndReturnError:(NSError **)outError {
    if (![super allocateRenderResourcesAndReturnError:outError]) {
        return NO;
    }
    
    // Validate that the bus formats are compatible.
    // Allocate your resources.
    
    return YES;
}

// Deallocate resources allocated in allocateRenderResourcesAndReturnError:
// Subclassers should call the superclass implementation.
- (void)deallocateRenderResources {
    // Deallocate your resources.
    [super deallocateRenderResources];
}

#pragma mark - AUAudioUnit (AUAudioUnitImplementation)

// Block which subclassers must provide to implement rendering.
- (AUInternalRenderBlock)internalRenderBlock {
    // Capture in locals to avoid Obj-C member lookups. If "self" is captured in render, we're doing it wrong. See sample code.
    
    return ^AUAudioUnitStatus(AudioUnitRenderActionFlags *actionFlags, const AudioTimeStamp *timestamp, AVAudioFrameCount frameCount, NSInteger outputBusNumber, AudioBufferList *outputData, const AURenderEvent *realtimeEventListHead, AURenderPullInputBlock pullInputBlock) {
        // Do event handling and signal processing here.
        
        return noErr;
    };
}

@end

