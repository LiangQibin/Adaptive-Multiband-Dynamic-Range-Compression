//
//  frontPage.c
//  Kash_Stereo
//
//  Created by SSPRL on 8/29/19.
//  Copyright © 2019 SSPRL. All rights reserved.
//

#include "dsp.h"
#include "overlapAdd.hpp"


DCRejectionFilter dc = DCRejectionFilter();
Configuration* ConfigSettings1 = Configuration::getInstance();
Transform *X = newTransform(NFFT);
Transform *Y = newTransform(NFFT);
Transform *Z = newTransform(NFFT);

int frameCount=0;
//Window Parameters
int w_len = 2*FRAME_SIZE;
Float32 *win = (Float32*)malloc(w_len* sizeof(Float32));
Float32 *sys_win = (Float32*)malloc(w_len/2* sizeof(Float32));
Float32 scalingFactor = 0;
Float32 sum_win = 0;

//Buffer that holds 2 frames windowed of data.
static Float32 *in_buffer = (Float32*)calloc(2*FRAME_SIZE, sizeof(Float32));
//Buffer that hold previous frame of data.
static Float32 *prev_buffer = (Float32*)calloc(FRAME_SIZE, sizeof(Float32));
static Float32 *output_final_l = (Float32*)calloc(FRAME_SIZE, sizeof(Float32));
static Float32 *output_final_r = (Float32*)calloc(FRAME_SIZE, sizeof(Float32));
static Float32 *output_old_l = (Float32*)calloc(FRAME_SIZE, sizeof(Float32));
static Float32 *output_old_r = (Float32*)calloc(FRAME_SIZE, sizeof(Float32));
static Float32 *float_output_l = (Float32*)calloc(NFFT, sizeof(Float32));
static Float32 *float_output_r = (Float32*)calloc(NFFT, sizeof(Float32));
static Float32 *input = (Float32*)calloc(FRAME_SIZE, sizeof(Float32));
static Float32 *fftmagoutput = (Float32*)calloc(NFFT, sizeof(Float32));


// Compression Parameters
int Threshold;
float ratio;
float tauAttack;
bool adaptive;
float fix_tauRelease;
int Knee = 10, M = 15;
Float32 tauRelease= 0.2;
int gain_method;

//Adaptive Release Time
Float32 Spectral_Flux=0;
Float32 gaama = 0.8;   // How the Release time will change according to SF.


//*****
Float32* output_real_l = (Float32*)calloc(NFFT,sizeof(Float32));
Float32* output_imag_l = (Float32*)calloc(NFFT,sizeof(Float32));
Float32* output_real_r = (Float32*)calloc(NFFT,sizeof(Float32));
Float32* output_imag_r = (Float32*)calloc(NFFT,sizeof(Float32));
Float32* fftmag_prev = (Float32*)calloc(NFFT,sizeof(Float32));

// Storing the Gain values for NFFT values from the Audiogram and Interpolation
Float32* AudiogramLeft = (Float32*)malloc(9* sizeof(Float32));//(Float32*)ConfigSettings1->getAudiogramLeft();
Float32* AudiogramRight = (Float32*)malloc(9*sizeof(Float32));//(Float32*)ConfigSettings1->getAudiogramRight();


void update(){
    Threshold=ConfigSettings1->getThreshold() - 95;
    ratio=ConfigSettings1->getRatio();
    tauAttack= (ConfigSettings1->getAttackTime())*pow(10,-3);
    adaptive = ConfigSettings1->getIsAdaptive();    // If Release time is adaptive, set it to 1.
    fix_tauRelease = (ConfigSettings1->getRleaseTime())*pow(10, -3);
    gain_method = ConfigSettings1->getMethod();
    
    for (int i=0;i<9;i++){
    AudiogramLeft[i] = (Float32)ConfigSettings1->getAudiogramLeft()[i];
    AudiogramRight[i] = (Float32)ConfigSettings1->getAudiogramRight()[i];
    }
}


void window2(){
     for (int i = 0; i < w_len; ++i){
     //Analysis Window - blackman Harris Window
     win[i] = 0.35875 - 0.48829*cosf(2*M_PI*i/(w_len)) + 0.14128*cosf(4*M_PI*i/w_len)-0.01168*cosf(6*M_PI*i/w_len);
     }
     scalingFactor = (FRAME_SIZE)/scalingFactor;
     for (int i = 0; i < w_len/2; ++i)
     {
     sys_win[i] = 0.54 - 0.46*cosf(2*M_PI*i/(w_len/2-1));
     }
}



void window1(UInt32 Len){
    for (UInt32 i = 0; i < (Len*2); ++i){
        win[i] = 0.5 * (1 - cosf(2 * M_PI*(i + 1) / ((Len*2) + 1)));
        sum_win += win[i];
    }
    
    for ( UInt32 i = 0; i < (Len*2); ++i){
        win[i] = (win[i]*Len)/sum_win;
    }
    
    for (UInt32 i = 0; i < Len; ++i){
        sys_win[i] = 1 / (win[i] + win[i + Len]);
    }
}
overlapAdd OA;


void initializeDSP(){
    update();
    printf("Updated values");
    ConfigSettings1->displaySetting();
   
    window1(FRAME_SIZE);
    
}

void processing(audioData* audio, UInt32 inNumberFrames){
    frameCount++;
    dc.ProcessInplace(audio, inNumberFrames);
   
    Float32* curr_buffer = audio->left;
    //Left right channel of input are same. So we can consider only
    //left channel as input. Buffer that holds current frame data.
   
    for(UInt32 i =0;i<inNumberFrames;++i){
        in_buffer[i] = prev_buffer[i] * win[i];
        prev_buffer[i] = curr_buffer[i];
        in_buffer[i+inNumberFrames] = curr_buffer[i] * win[i+inNumberFrames];
    }
   
    X->doTransform(X,in_buffer);

    transformMagnitude(X, fftmagoutput);
    Spectral_Flux = spectralFlux(fftmagoutput, fftmag_prev, NFFT);
     tauRelease = adaptive_Releasetime(fftmagoutput, fftmag_prev,
                                      NFFT, fix_tauRelease, gaama,
                                      ConfigSettings1->getIsAdaptive());
    
    for(int i=0;i<NFFT;++i){
        fftmag_prev[i] = fftmagoutput[i];
    }
    
    ffcompressor(X->real,X->imaginary,
                 NFFT, SAMPLING_FREQUENCY,
                 Threshold, ratio,
                 tauAttack, tauRelease,
                 Knee, AudiogramLeft, AudiogramRight, M,
                 output_real_l, output_imag_l,
                 output_real_r, output_imag_r,
                 gain_method);
    
    Y->invTransform(Y,output_real_l, output_imag_l);
    Z->invTransform(Z,output_real_r, output_imag_r);
  
    for(UInt32 i=0;i<inNumberFrames;++i){
       
       output_final_l[i] = (output_old_l[i]+Y->real[i])*sys_win[i];
       output_old_l[i]=(Y->real[i+inNumberFrames]);
       output_final_r[i] = (output_old_r[i]+Z->real[i])*sys_win[i];
       output_old_r[i]=(Z->real[i+inNumberFrames]);
    }
   
    fir(output_final_l,float_output_l,inNumberFrames);
    fir(output_final_r,float_output_r,inNumberFrames);
 
    for (UInt32 i = 0; i<inNumberFrames; ++i){
        audio->left[i] = output_final_l[i];
        if (ConfigSettings1->getIsStereo()){
            audio->right[i] = output_final_r[i];
        }else{
            audio->right[i] = output_final_l[i];
        }
    }
    
}


