//
//  compression.h
//  Kash_compression
//
//  Created by SSPRL on 8/2/19.
//  Copyright © 2019 SSPRL. All rights reserved.
//

#ifndef compression_h
#define compression_h

#include "AudioFormat.h"
#include <stdio.h>
#include <map>
#include <iostream>
#import "spline.h"



static const int32_t buffer_size = 8;


void ffcompressor(float* x_real,float* x_imag, int frame_size, int fs,int Threshold,int ratio, float tauAttack, float tauRelease,int Knee, float* threshold_left,float* threshold_right, int M,float* output_real_l, float* output_imag_l,float* output_real_r, float* output_imag_r, int gain_method);
void gainsmoothing(float* cv, int frame_size, int fs, float tauAttack, float tauRelease, float* cvp);
void gaincomputer(float* lg,int frame_size, int Threshold, int ratio, int Knee, float *cv);
float spectralFlux(float* fftmag, float* fftmag_prev, int nFFT);
float adaptive_Releasetime(float* fftmag, float* fftmag_prev, int nFFT, float fix_tauRelease, float gaama, bool adaptive);
void DSLGain(float* threshold, float* gain, int inputLevel, int numChannels);
void halfGain(float* threshold, float* gain, int numChannels);
int energyLevel(float energyIndB);
typedef struct SpectralFluxBuffer{
   
    float threshold = 0.3;
    float Buffer[buffer_size] = {0};
    bool add(float x);
    bool isNoise();
    
    
}SPectralFluxBuffer;






 

#endif /* compression_h */
