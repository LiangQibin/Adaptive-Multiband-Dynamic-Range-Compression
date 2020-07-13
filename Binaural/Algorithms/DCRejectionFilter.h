/*
 
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 This class implements a DC Rejection Filter which is used to get rid of the DC component in an audio signal
 
 */


//#include "AudioBuffer.h"


#ifndef DCRejectionFilter__
#define DCRejectionFilter__

#include <AudioToolbox/AudioToolbox.h>
#include "AudioFormat.h"


class DCRejectionFilter
{
public:
	DCRejectionFilter();
    ~DCRejectionFilter();
    
	void ProcessInplace(audioData *audio, UInt32 numFrames);
    
    
private:
	Float32 mY1;
	Float32 mX1;
};

#endif /* defined(__aurioTouch3__DCRejectionFilter__) */
