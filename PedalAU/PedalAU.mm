//
//  PedalAUAudioUnit.m
//  PedalAU
//
//  Created by Lawrence Herman on 5/25/17.
//  Copyright © 2017 Lawrence Herman. All rights reserved.
//

#import "PedalAU.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreAudioKit/AUViewController.h>

// #import "FilterDSPKernel.hpp"
#import "BufferedAudioBus.hpp"

// ***************
// example has is viewcontroller extension with a .h
//#import "PedalViewControllerExt.h"

// filter sets up presets here

@interface PedalAUAudioUnit ()



// ADDED  // check out why no input bus in filter --uses BufferedAudioBusC++ Clas

@property AUAudioUnitBus *outputBus;
// @property AUAudioUnitBus *inputBus;
@property AUAudioUnitBusArray *inputBusArray;
@property AUAudioUnitBusArray *outputBusArray;

@end

// TO HERE



@implementation PedalAUAudioUnit {
    
    BufferedInputBus _inputBus;
    
    
}

@synthesize parameterTree = _parameterTree;


- (instancetype)initWithComponentDescription:(AudioComponentDescription)componentDescription options:(AudioComponentInstantiationOptions)options error:(NSError **)outError {
    
    self = [super initWithComponentDescription:componentDescription options:options error:outError];
    
    if (self == nil) {return nil; }
    
    printf("inside .mm PedalAU initWithcomponentDescription/n/n");
    
    // componentFlags 0x0000001e == SandboxSafe(2) + IsV3AudioUnit(4) + RequiresAsyncInstantiation(8) + CanLoadInProcess(0x10)
    NSLog(@"AUv3FilterDemo initWithComponentDescription:\n componentType: %c%c%c%c\n componentSubType: %c%c%c%c\n componentManufacturer: %c%c%c%c\n componentFlags: %#010x",
          FourCCChars(componentDescription.componentType),
          FourCCChars(componentDescription.componentSubType),
          FourCCChars(componentDescription.componentManufacturer),
          componentDescription.componentFlags);
    
    NSLog(@"Process Name: %s PID: %d\n", [[[NSProcessInfo processInfo] processName] UTF8String],
          [[NSProcessInfo processInfo] processIdentifier]);
    
    // initialize a default format for the busses.  ------ ADDED
    AVAudioFormat *defaultFormat = [[AVAudioFormat alloc] initStandardFormatWithSampleRate:44100.0 channels:2];
    
    
    // create a DSP Kernal to handle the signal processing? from filter"
    
    // Create parameter objects.  checkout need for flags
    AUParameter *param1 = [AUParameterTree createParameterWithIdentifier:@"param1" name:@"Parameter 1"
             address:0 min:0 max:100 unit:kAudioUnitParameterUnit_Percent unitName:nil flags:kAudioUnitParameterFlag_IsReadable |
                       kAudioUnitParameterFlag_IsWritable |
                       kAudioUnitParameterFlag_CanRamp
               valueStrings:nil dependentParameters:nil];
    
    //  update when needed
//    AUParameter *param2 = [AUParameterTree createParameterWithIdentifier:@"param2" name:@"Parameter 2" address:myParam2 min:0 max:100 unit:kAudioUnitParameterUnit_Percent unitName:nil flags:0 valueStrings:nil dependentParameters:nil];
    
    // Initialize the parameter values.
    param1.value = 0.5;
//    param2.value = 0.5;
    
    // kernal work here in filter
    
    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[ param1 ]];
    
    // Create the input and output busses (AUAudioUnitBus).
    
    // ADDED
    
    
    _inputBus.init(defaultFormat, 8);
    _outputBus = [[AUAudioUnitBus alloc] initWithFormat:defaultFormat error:nil];
    
    
    
    // Create the input and output bus arrays (AUAudioUnitBusArray).
    
    // ADDED --- one change no .bus on end of _inputBus
    
    _inputBusArray  = [[AUAudioUnitBusArray alloc] initWithAudioUnit:self busType:AUAudioUnitBusTypeInput busses: @[_inputBus.bus]];
    _outputBusArray = [[AUAudioUnitBusArray alloc] initWithAudioUnit:self busType:AUAudioUnitBusTypeOutput busses: @[_outputBus]];
    
    // Make a local pointer to the kernel to avoid capturing self.
   // __block FilterDSPKernel *filterKernel = &_kernel;
    
//    // *********************
//    // implementorValueObserver is called when a parameter changes value.
//    _parameterTree.implementorValueObserver = ^(AUParameter *param, AUValue value) {
//        /*
//         This block, used only in an audio unit implementation, receives all externally-generated
//         changes to parameter values. It should store the new value in its audio signal processing
//         state (assuming that that state is separate from the AUParameter object).
//         */
//        filterKernel->setParameter(param.address, value);
//    };
//
//    // implementorValueProvider is called when the value needs to be refreshed.
//    _parameterTree.implementorValueProvider = ^(AUParameter *param) {
//        /*
//         The audio unit should return the current value for this parameter; the AUParameterNode
//         will store the value.
//         */
//        return filterKernel->getParameter(param.address);
//    };
    
    
    // A function to provide string representations of parameter values.
    _parameterTree.implementorStringFromValueCallback = ^(AUParameter *param, const AUValue *__nullable valuePtr) {
        AUValue value = valuePtr == nil ? param.value : *valuePtr;
        
        switch (param.address) {
            case 0:
                return [NSString stringWithFormat:@"%.f", value];
            default:
                return @"?";
        }
    };
    
    self.maximumFramesToRender = 512;
    
    return self;
}

//-(void)dealloc {
//    _factoryPresets = nil;
//    NSLog(@"AUv3FilterDemo Dealloc\n");
//}


#pragma mark - AUAudioUnit Overrides

// If an audio unit has input, an audio unit's audio input connection points.
// Subclassers must override this property getter and should return the same object every time.
// See sample code.


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
    
    if (self.outputBus.format.channelCount != _inputBus.bus.format.channelCount) {
        if (outError) {
            *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:kAudioUnitErr_FailedInitialization userInfo:nil];
        }
        // Notify superclass that initialization was not successful
        self.renderResourcesAllocated = NO;
        
        return NO;
    }
    
    _inputBus.allocateRenderResources(self.maximumFramesToRender);
    
    // kernel work in filter
    
    return YES;
}

// Deallocate resources allocated by allocateRenderResourcesAndReturnError:
// Subclassers should call the superclass implementation. Hosts should call this after finishing rendering.
- (void)deallocateRenderResources {
    _inputBus.deallocateRenderResources();
    
    [super deallocateRenderResources];
}

#pragma mark - AUAudioUnit (AUAudioUnitImplementation)

// Block which subclassers must provide to implement rendering.
- (AUInternalRenderBlock)internalRenderBlock {
    // Capture in locals to avoid Obj-C member lookups. If "self" is captured in render, we're doing it wrong. See sample code.
    
 // Specify captured objects are mutable.
//    __block FilterDSPKernel *state = &_kernel;
    
    __block BufferedInputBus *input = &_inputBus;
    
    return ^AUAudioUnitStatus(
                              AudioUnitRenderActionFlags *actionFlags,
                              const AudioTimeStamp       *timestamp,
                              AVAudioFrameCount           frameCount,
                              NSInteger                   outputBusNumber,
                              AudioBufferList            *outputData,
                              const AURenderEvent        *realtimeEventListHead,
                              AURenderPullInputBlock      pullInputBlock) {
        AudioUnitRenderActionFlags pullFlags = 0;
        
        AUAudioUnitStatus err = input->pullInput(&pullFlags, timestamp, frameCount, 0, pullInputBlock);
        
        if (err != 0) { return err; }
        
        AudioBufferList *inAudioBufferList = input->mutableAudioBufferList;
        
        /*
         Important:
         If the caller passed non-null output pointers (outputData->mBuffers[x].mData), use those.
         
         If the caller passed null output buffer pointers, process in memory owned by the Audio Unit
         and modify the (outputData->mBuffers[x].mData) pointers to point to this owned memory.
         The Audio Unit is responsible for preserving the validity of this memory until the next call to render,
         or deallocateRenderResources is called.
         
         If your algorithm cannot process in-place, you will need to preallocate an output buffer
         and use it here.
         
         See the description of the canProcessInPlace property.
         */
        
        // If passed null output buffer pointers, process in-place in the input buffer.
        AudioBufferList *outAudioBufferList = outputData;
        if (outAudioBufferList->mBuffers[0].mData == nullptr) {
            for (UInt32 i = 0; i < outAudioBufferList->mNumberBuffers; ++i) {
                outAudioBufferList->mBuffers[i].mData = inAudioBufferList->mBuffers[i].mData;
            }
        }
        
//        state->setBuffers(inAudioBufferList, outAudioBufferList);
//        state->processWithEvents(timestamp, frameCount, realtimeEventListHead, nil /* MIDIOutEventBlock */);
        
        return noErr;
    };
}

// Expresses whether an audio unit can process in place.
// In-place processing is the ability for an audio unit to transform an input signal to an
// output signal in-place in the input buffer, without requiring a separate output buffer.
// A host can express its desire to process in place by using null mData pointers in the output
// buffer list. The audio unit may process in-place in the input buffers.
// See the discussion of renderBlock.
// Partially bridged to the v2 property kAudioUnitProperty_InPlaceProcessing, the v3 property is not settable.
//- (BOOL)canProcessInPlace {
//    return YES;
//}


#pragma mark - AUAudioUnit ViewController related

//- (NSIndexSet *)supportedViewConfigurations:(NSArray<AUAudioUnitViewConfiguration *> *)availableViewConfigurations {
//    NSMutableIndexSet *result = [NSMutableIndexSet indexSet];
//    for (unsigned i = 0; i < [availableViewConfigurations count]; ++i)
//    {
//        // The two views we actually have
//        if ((availableViewConfigurations[i].width >= 800 && availableViewConfigurations[i].height >= 500) ||
//            (availableViewConfigurations[i].width <= 400 && availableViewConfigurations[i].height <= 100) ||
//            // Full-screen size or our own window, always supported, we return our biggest view size in this case
//            (availableViewConfigurations[i].width == 0 && availableViewConfigurations[i].height == 0)) {
//            [result addIndex:i];
//        }
//    }
//
//    return result;
//}
//
//- (void)selectViewConfiguration:(AUAudioUnitViewConfiguration *)viewConfiguration {
//    return [self.auViewController handleSelectViewConfiguration:viewConfiguration];
//}

@end

