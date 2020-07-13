//
//  MBAC.h
//  Binaural
//
//  Created by Kashyap Patel on 12/4/19.
//  Copyright © 2019 Kashyap Patel. All rights reserved.
//

#ifndef MBAC_h
#define MBAC_h

#include <stdio.h>
#include <MacTypes.h>
#include<iostream>
#include <string>
#include <sstream>
#include <fstream>
#include <vector>
#import "Configuration.h"
#import "spline.h"
#include "math.h"
#include "AudioFormat.h"
#ifndef MAX
#define MAX(a,b)            (((a) > (b)) ? (a) : (b))
#endif
using namespace std;

class MBAC{
    
    int _threshold;
    float _ratio;
    float _attack;
    float _release;
    bool _adaptive;
    int _knee;
    int _M;
    int* _hearingThresholdLeft = (int*)calloc(9, sizeof(int));
    int* _hearingThresholdRight = (int*)calloc(9, sizeof(int));
    float _fastRelease = 200;
    float _slowRelease = 800;
    int inputLevel;
    float* _gainLeft = (float*)calloc(9, sizeof(float));
    float* _gainRight = (float*)calloc(9, sizeof(float));
    float* _gainLFull = (float*)calloc(NFFT, sizeof(float));
    float* _gainRFull = (float*)calloc(NFFT, sizeof(float));
    int _gainMethod;
    int bands =9;
    Float32 center_freq[9] = {8,16,24,32,48,64,96,128,192};
    
public:
    virtual ~MBAC();
    MBAC();
    void getParameters();
    int getInputLevel(float energy);
    float getSpectralFlux();
    void applyMBAC(Float32 *leftReal, Float32 *leftIm, Float32 *rightReal, Float32 *rightIm, int numFrames);
    
private:
    void insertionGain(int inputLevel);
    void compressionFunction();
    void gainSmoothing();
    float* lg = (float*)calloc(NFFT, sizeof(float));
    float* gain_l = (float*)calloc(NFFT, sizeof(float));
    float* cv = (float*)calloc(NFFT, sizeof(float));
    float* cvp = (float*)calloc(NFFT, sizeof(float));
    float* overshoot = (float*)calloc(FRAME_SIZE, sizeof(float));
    float* rect = (float*)calloc(FRAME_SIZE, sizeof(float));
    float _frameEnergy = 0;
    void DSLGain(int* threshold, float* gain, int inputLevel, int numChannels);
    void HalfGain(int* threshold, float* gain, int numChannels);
    void gainCalculation(int inputLevel);
    void interpolation();
    void getTimeConstants();
};
#endif /* MBAC_h */
