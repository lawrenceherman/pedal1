//
//  PedalAUAudioUnit.h
//  PedalAU
//
//  Created by Lawrence Herman on 5/25/17.
//  Copyright © 2017 Lawrence Herman. All rights reserved.
//

#ifndef PedalAU_h
#define PedalAU_h

#import <AudioToolbox/AudioToolbox.h>

@class PedalViewController;

#define FourCCChars(CC) ((int)(CC)>>24)&0xff, ((int)(CC)>>16)&0xff, ((int)(CC)>>8)&0xff, (int)(CC)&0xff

// before update
//// Define parameter addresses.
//extern const AudioUnitParameterID myParam1;
//extern const AudioUnitParameterID myParam2;

@interface PedalAUAudioUnit : AUAudioUnit

@property (weak) PedalViewController* auViewController;


@end

#endif
