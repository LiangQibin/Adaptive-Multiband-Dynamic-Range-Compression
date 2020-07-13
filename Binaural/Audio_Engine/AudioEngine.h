//
//  AudioController.h
//  Kash_Stereo
//
//  Created by SSPRL on 8/28/19.
//  Copyright © 2019 SSPRL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>   // For time.


#import "DCRejectionFilter.h"
#import "AudioFormat.h"
#import "dsp.h"
#import "RingBuffer.h"

#ifndef max
#define max( a, b ) ( ((a) > (b)) ? (a) : (b) )
#endif

#ifndef min
#define min( a, b ) ( ((a) < (b)) ? (a) : (b) )
#endif


NS_ASSUME_NONNULL_BEGIN

@interface AudioEngine : NSObject{
    
    AudioUnit               _rioUnit;
    DCRejectionFilter*      _dcRejectionFilter;
    AVAudioPlayer*          _audioPlayer;   // for button pressed sound
    BOOL                    _audioChainIsBeingReconstructed;
}


-(OSStatus)startIOUnit;
-(OSStatus)stopIOUnit;
-(void)setupAudioSession;
-(void)setupIOunit;
-(void)setupAudioChain;
- (void) processAudio: (AudioBufferList*) bufferList;

@end

extern AudioEngine* audioEngine;


NS_ASSUME_NONNULL_END
