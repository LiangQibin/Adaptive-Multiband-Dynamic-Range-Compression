//
//  frontPage.h
//  Kash_Stereo
//
//  Created by SSPRL on 8/29/19.
//  Copyright © 2019 SSPRL. All rights reserved.
//

#ifndef dsp_h
#define dsp_h


#include <stdio.h>

#include "AudioFormat.h"
#import "spline.h"
#import "Transforms.h"
#import "compression.h"
#import "FIR.h"
#import "Configuration.h"
#import "DCRejectionFilter.h"
#include <future>
#import <QuartzCore/QuartzCore.h>   // For time.
//#import "settings.h"

void processing(audioData* audio, UInt32 inNumFrames);
void interpolation();
void window1();
void window2();
void initializeDSP();
void update();
void processData(float *data, float *w);
 



//int fame;












#endif /* frontPage_h */






