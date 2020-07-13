//
//  MBAC.c
//  Binaural
//
//  Created by Kashyap Patel on 12/4/19.
//  Copyright © 2019 Kashyap Patel. All rights reserved.
//

#include "MBAC.h"
Configuration* settings = Configuration::getInstance();

int fs = SAMPLING_FREQUENCY;



MBAC::~MBAC(){
    
}

MBAC::MBAC(){
    getParameters();
}

void MBAC::getParameters(){
    _threshold = settings->getThreshold();
    _ratio = settings->getRatio();
    _attack = settings->getAttackTime();
    _release = settings->getRleaseTime();
    _adaptive = settings->getIsAdaptive();
    _knee = 10;
    _M = 5;
    _gainMethod = 1;
    
    for (int i=0;i<9;i++){
        _hearingThresholdLeft[i] = settings->getAudiogramLeft()[i];
        _hearingThresholdRight[i] = settings->getAudiogramRight()[i];
    }
    
}



void MBAC::applyMBAC(Float32 *leftReal, Float32 *leftIm, Float32 *rightReal, Float32 *rightIm, int inNumFrames){
    
    _frameEnergy = 0;
    for (int i=0;i<inNumFrames;i++){
        int mag = pow(leftReal[i],2)+pow(leftIm[i],2);
        lg[i] = 10*log10f(MAX(mag,pow(10,-6)));
        _frameEnergy += mag;
    }
    
    inputLevel = getInputLevel(_frameEnergy);
    insertionGain(inputLevel);
    compressionFunction();
    getTimeConstants();
    
    for(int i=0;i<NFFT;i++){
       // printf("%f\n",cvp[i]);
        gain_l[i] = pow(10,(_M+cvp[i])/20);
        leftReal[i] = leftReal[i]*gain_l[i];
        leftIm[i] = leftIm[i]*gain_l[i];
        
        gain_l[i] = pow(10,(_M+cvp[i])/20);
        //printf("%f\n",gain_l[i]);
        rightReal[i] = rightReal[i]*gain_l[i];
        rightIm[i] = rightIm[i]*gain_l[i];
    }
    
    
}

void MBAC::getTimeConstants(){
    
}

void MBAC::gainSmoothing(){
    float taufs = _attack*fs;
    float alphaAtt=0, alphaRel = 0, state = 0;
    
    if (_attack>0){
        alphaAtt = expf(-NFFT/taufs);
    }else{
        alphaAtt = 0;
    }
    
    taufs = _release*fs;
    
    if (_release>0){
        alphaRel = expf(-NFFT/taufs);
    }else{
        alphaRel = 0;
    }
    
    for(int i=0;i<NFFT;i++){
        cvp[i] = cv[i];
        if (cvp[i]>state){
            state = alphaAtt*state + (1 - alphaAtt)*cvp[i];
        }else{
            state = alphaRel*state;
        }
        cvp[i] = -state;
    }
}

void MBAC::compressionFunction(){
    float slope = 1.0/_ratio - 1;
    float w2 = _knee/2.0;
    float a = 1.0/(2*_knee);
    
    for(int i=0;i<NFFT;i++){
        overshoot[i] = lg[i] - pow(10,_threshold/20);
        if (_knee >0){
            if((overshoot[i]>-w2)&&(overshoot[i]<w2))
                rect[i] = a*pow(overshoot[i]+w2,2);
            else
                rect[i] = MAX(overshoot[i],0);
        }else
            rect[i] = MAX(overshoot[i],0);
        
        cv[i] = -1*rect[i]*slope;
    }
    return;
}

int MBAC::getInputLevel(float frameEnergy){
    return 0;
}

void MBAC::insertionGain(int inputLevel){
    gainCalculation(inputLevel);
    interpolation();
    for (int i=0;i<NFFT;i++){
        lg[i] = lg[i]*pow(10,_gainLFull[i]/20);
    }
    
    
}

void MBAC::interpolation(){
    spline(bands,center_freq,_gainLeft,NFFT,_gainLFull);
    spline(bands, center_freq, _gainRight, NFFT, _gainRFull);
}

void MBAC::gainCalculation(int inputLevel){
    //Half Gain Rule 0, DSL Rule 1
   if (_gainMethod==1){
        DSLGain(_hearingThresholdLeft, _gainLeft, inputLevel, bands);
        DSLGain(_hearingThresholdRight, _gainRight, inputLevel, bands);
    }else{
        HalfGain(_hearingThresholdLeft, _gainLeft, bands);
        HalfGain(_hearingThresholdRight, _gainRight, bands);
    }
}

void MBAC::HalfGain(int *threshold, float *gain, int bands){
    for (int i=0; i<bands; i++){
        gain[i] = threshold[i]/2;
    }
    gain[0] -= 10;
    gain[1] -= 5;
}


float _DSLbyHand[23][28] = {
        {0,46,49,45,43,43,46,47,45,38,56,59,55,53,53,56,57,55,48,57,65,68,66,69,72,72,69,57},
        {5,49,52,48,46,47,50,51,49,41,59,62,58,56,56,59,60,58,51,60,68,70,68,72,74,74,72,60},
        {10,53,55,52,50,50,53,54,53,45,61,64,61,59,59,62,64,62,54,62,70,72,71,74,77,77,74,63},
        {15,56,58,55,53,54,57,58,56,49,64,67,64,62,62,66,67,65,58,65,73,74,73,76,79,80,77,66},
        {20,59,62,58,56,57,60,62,60,53,67,70,67,65,66,69,70,68,61,68,75,77,76,79,82,82,80,69},
        {25,63,65,62,60,61,64,65,64,57,70,73,69,68,69,72,73,71,65,71,78,79,78,81,84,85,82,72},
        {30,65,66,63,62,63,66,67,65,60,71,74,71,69,70,73,75,73,67,72,78,80,79,82,85,86,83,73},
        {35,67,68,65,63,65,68,69,68,62,73,75,72,71,72,75,76,75,69,74,80,81,80,83,86,87,84,75},
        {40,70,70,67,66,67,70,72,70,65,76,77,74,72,74,77,78,77,72,77,81,82,81,85,88,88,86,77},
        {45,73,73,69,68,70,73,74,73,69,78,79,76,75,76,79,81,79,75,79,83,84,83,86,89,90,88,80},
        {50,77,75,72,71,73,76,77,76,72,81,81,78,77,79,82,83,82,78,82,85,85,85,88,91,92,90,83},
        {55,81,79,76,75,76,79,80,79,76,85,85,82,81,81,84,86,85,81,86,88,89,88,90,93,94,92,86},
        {60,84,82,79,79,79,82,83,81,79,89,88,85,84,85,88,90,89,85,90,92,92,91,94,96,98,96,89},
        {65,86,84,81,81,82,84,85,84,82,93,91,88,87,89,92,94,93,89,93,94,94,94,97,100,101,99,93},
        {70,89,86,83,83,84,87,88,87,85,97,95,92,91,93,96,98,97,94,97,98,98,97,100,103,104,102,97},
        {75,92,89,86,86,87,90,91,89,88,101,99,96,95,97,100,101,99,98,101,101,101,101,104,106,108,106,101},
        {80,94,92,89,89,90,93,93,92,91,104,102,99,99,100,103,103,102,101,106,105,105,104,107,110,111,109,105},
        {85,98,94,92,92,93,95,96,95,94,108,104,102,102,103,105,106,105,104,109,109,108,108,111,113,115,113,109},
        {90,99,97,95,95,96,98,100,99,97,109,107,105,105,106,108,110,109,107,110,112,112,111,114,116,118,117,113},
        {95,103,101,98,98,99,102,104,103,102,113,111,108,108,109,112,114,113,112,115,116,116,115,117,120,121,119,117},
        {100,107,105,102,102,103,106,107,106,106,117,115,112,112,113,116,117,116,116,118,120,119,119,120,122,124,122,121},
        {105,111,106,106,106,107,108,109,109,108,121,116,116,116,117,118,119,119,118,122,123,123,122,123,124,126,124,123},
        {110,115,110,110,110,110,111,113,111,111,125,120,120,120,120,121,123,121,121,126,126,126,125,125,126,128,126,126}
};


void MBAC::DSLGain(int* threshold, float* gain, int inputLevel, int numBands){
    //numChannels = 9;
    //gain{0.25, 0.5, 1, 1.5, 2, 3, 4, 6, 8}
    // Threshold needs to be a multiple of 5.
    //Test Threshold

    for (int i=0; i<numBands; i++){
        threshold[i] = 10*i;
        int rem = (threshold[i] %5);
        if(rem != 0){
            threshold[i] += rem;
        }
        int thresholdRow = threshold[i]/5;
        switch (inputLevel) {
            case 0: // Soft Case
                gain[i] = _DSLbyHand[thresholdRow][i+1];
            case 1: // Moderate Case
                gain[i] = _DSLbyHand[thresholdRow][10+i];
            case 2:  // Loud Case
                gain[i] = _DSLbyHand[thresholdRow][19+i];
            default:
                continue;
        }
    }
}








