//
//  compression.c
//  Kash_compression
//
//  Created by SSPRL on 8/2/19.
//  Copyright © 2019 SSPRL. All rights reserved.
//

#include "compression.h"
#include "math.h"
#include "stdlib.h"
#ifndef MAX
#define MAX(a,b)            (((a) > (b)) ? (a) : (b))
#endif


/*//Parameters for the compression
Sampling Rate, Threshold, Ratio, Attack Time, Release Time, Knee, Make-up Gain
*/

float DSLbyHand[23][28] = {
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




SpectralFluxBuffer* SFB = new SpectralFluxBuffer;


float* lg_l = (float*)calloc(NFFT, sizeof(float));
float* lg_r = (float*)calloc(NFFT, sizeof(float));
float* gain_l = (float*)calloc(NFFT, sizeof(float));
float* cv = (float*)calloc(NFFT, sizeof(float));
float* cvp = (float*)calloc(NFFT, sizeof(float));
float* overshoot = (float*)calloc(FRAME_SIZE, sizeof(float));
float* rect = (float*)calloc(FRAME_SIZE, sizeof(float));

float* gainLeft = (float*)calloc(9, sizeof(float));
float* gainRight = (float*)calloc(9, sizeof(float));

Float32 *spl_left = (Float32*)malloc(NFFT* sizeof(Float32));
Float32 *spl_right = (Float32*)malloc(NFFT* sizeof(Float32));
Float32 center_freq[9] = {8,16,24,32,48,64,96,128,192};
Float32 gain[9] = {15,18,26,26,30,20,20,30,40};
int inputLevel = 0;

float target_SPL_soft[9] = {84, 82, 81, 83, 84, 90, 93, 95, 94};
float target_SPL_mod[9] = {89, 88, 88, 91, 93, 100, 103, 105, 104};
float target_SPL_loud[9] = {90, 92, 94, 97, 100, 106, 111, 113, 109};

float input_soft[9] = {49, 53, 48, 47, 48, 43, 38, 37, 39};
float input_mode[9] = {59, 63, 58, 57, 58, 53, 48, 46, 49};
float input_loud[9] = {61, 71, 72, 71, 75, 70, 63, 61, 59};

   

bool SpectralFluxBuffer::add(float x){
    
    Buffer[0] = x;
    
    for (int i=1;i<buffer_size;i++){
        Buffer[i] = Buffer[i-1];
        
    }
    return true;
    
}

bool SpectralFluxBuffer::isNoise(){
    bool tmp = false;
    for(int i=0;i<buffer_size;i++){
        if (Buffer[i]<threshold)
            tmp = true;
        else
            tmp =false;
    }
    return tmp;
}

float* thres = (float*)calloc(9, sizeof(float));
float* gai = (float*)calloc(9, sizeof(float));

void DSLGain(float* threshold, float* gain, int inputLevel, int numChannels){
    //numChannels = 9;
    //gain{0.25, 0.5, 1, 1.5, 2, 3, 4, 6, 8}
    // Threshold needs to be a multiple of 5.
    //Test Threshold

    for (int i=0; i< numChannels; i++){
        int rem = ((int)threshold[i] % 5);
//        if(rem != 0){
//            threshold[i] += 5 - rem;
//        }
        int thresholdRow = threshold[i]/5;
        switch (inputLevel) {
            case 0: // Soft Case
                gain[i] = DSLbyHand[thresholdRow][i+1] - input_soft[i];
                continue;
            case 1: // Moderate Case
                gain[i] = DSLbyHand[thresholdRow][10+i] - input_mode[i];
                continue;
            case 2:  // Loud Case
                gain[i] = DSLbyHand[thresholdRow][19+i] - input_loud[i];
                continue;
            default:
                continue;
        }
    }
    
  
}


void halfGain(float* threshold, float* gain, int numChannels){
    for(int i = 0; i< numChannels; i++){
        if (i == 0){
            gain[i] = threshold[i]/2 - 10;
        }
        if (i == 1){
            gain[i] = threshold[i]/2 -5;
        }else{
            gain[i] = threshold[i]/2;
        }
    }
}

void gaincomputer(float* lg,int frame_size, int Threshold, int ratio, int Knee, float *cv){
    float slope = 1.0/ratio - 1;
    float w2 = Knee/2.0;
    float a = 1.0/(2*Knee);
    
    for(int i=0;i<frame_size;i++){
        overshoot[i] = lg[i] - pow(10,Threshold/20);
        if (Knee >0){
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


void gainsmoothing(float* cv, int frame_size, int fs, float tauAttack, float tauRelease, float* cvp){
    float taufs = tauAttack*fs;
    float alphaAtt=0, alphaRel = 0, state = 0;
    
    
    if (tauAttack>0){
        alphaAtt = expf(-frame_size/taufs);
    }else{
        alphaAtt = 0;
    }
    
    taufs = tauRelease*fs;
    
    if (tauRelease>0){
        alphaRel = expf(-frame_size/taufs);
    }else{
        alphaRel = 0;
    }
    
    for(int i=0;i<frame_size;i++){
        cvp[i] = cv[i];
        if (cvp[i]>state){
            state = alphaAtt*state + (1 - alphaAtt)*cvp[i];
        }else{
            state = alphaRel*state;
        }
        cvp[i] = -state;
    }
    
   return;
}

float spectralFlux(float* fftmag, float* fftmag_prev, int nFFT){
    
    float sum=0;
    for (int i=0;i<nFFT;i++){
        sum = sum + fabsf(fftmag[i]-fftmag_prev[i]);
    }
    SFB->add(sum);
   // printf("%f\n",sum);
    return sum;
    
}

float adaptive_Releasetime(float* fftmag, float* fftmag_prev, int nFFT, float fix_tauRelease, float gaama, bool adaptive){
    if (!adaptive){
       // printf("%f\n",fix_tauRelease);
        return fix_tauRelease;
    }else{
       // printf("Adaptive\n");
        float SF = spectralFlux(fftmag,fftmag_prev,nFFT);
        float a = fix_tauRelease/pow(SF,gaama);
        //printf("%f",MAX(a, fix_tauRelease));
       // printf("%f\n",MAX(a, fix_tauRelease));
        return MAX(a, fix_tauRelease);
    }
    
    
}

int energyLevel(float energyIndB){
    if (energyIndB < 50){
        return 0;
    }if (energyIndB > 50 && energyIndB < 70){
        return 1;
    }else{
        return 2;
    }
}
   
int j=0;

void interpolation(float* gainLeft, float* gainRight){
    spline(9, center_freq, gainLeft, NFFT, spl_left);
    spline(9, center_freq, gainRight, NFFT, spl_right);
}

void ffcompressor(float* x_real,float* x_imag, int frame_size, int fs,int Threshold,int ratio, float tauAttack, float tauRelease,int Knee, float* threshold_left,float* threshold_right, int M,float* output_real_l, float* output_imag_l,float* output_real_r, float* output_imag_r, int gain_method){
    
    float frameEnergy = 0;
    
    for (int i=0; i<frame_size; i++){
        int mag = pow(x_real[i],2)+pow(x_imag[i],2);
        lg_l[i] = 10*log10f(MAX(mag, pow(10,-6)));
        frameEnergy += mag;
    }
    
    frameEnergy = sqrt(frameEnergy);
    float frameEnergyIndB = 10*log10f(MAX(frameEnergy, pow(10,-6))) + 95;
    int input_level = energyLevel(frameEnergyIndB);

    if (gain_method == 0){
        halfGain(threshold_left, gainLeft, 9);
        halfGain(threshold_right, gainRight, 9);
    }
    if (gain_method == 1){
        DSLGain(threshold_left, gainLeft, input_level, 9);
        DSLGain(threshold_right, gainRight, input_level, 9);
    }

    interpolation(gainLeft, gainRight);
    
    for (int i=0;i<frame_size;i++){
        lg_r[i] = lg_l[i] + spl_right[i];
        lg_l[i] = lg_l[i] + spl_left[i];
    }
    printf("%d", gain_method);
//    /* check*/
//
//    thres[0] = 60;
//    thres[1] = 60;
//    thres[2] = 65;
//    thres[3] = 70;
//    thres[4] = 75;
//    thres[5] = 80;
//    thres[6] = 85;
//    thres[7] = 90;
//    thres[8] = 95;
//
////    for(int i=0; i<9; i++){
////        thres[i] = 80;
////    }
//
//
//
//    DSLGain((float*)thres, gai, 2, 9);
//
//    while(j<1){
//        for(int i=0;i<9;i++){
//            std::cout <<  thres[i] << " ";
//            std::cout << gai[i] ;
//            std::cout<< "\n";
//        }
//        j++;
//    }
    
    gaincomputer(lg_l,frame_size, Threshold, ratio, Knee, cv);
    gainsmoothing(cv,frame_size, fs, tauAttack, tauRelease,cvp);
    
    for(int i=0;i<frame_size;i++){
       // printf("%f\n",cvp[i]);
        gain_l[i] = pow(10,(M+cvp[i])/20);
        output_real_l[i] = x_real[i]*gain_l[i];
        output_imag_l[i] = x_imag[i]*gain_l[i];
    }
     
    gaincomputer(lg_r,frame_size, Threshold, ratio, Knee, cv);
    gainsmoothing(cv,frame_size, fs, tauAttack, tauRelease,cvp);
    
    for(int i=0;i<frame_size;i++){
        gain_l[i] = pow(10,(M+cvp[i])/20);
        //printf("%f\n",gain_l[i]);
        output_real_r[i] = x_real[i]*gain_l[i];
        output_imag_r[i] = x_imag[i]*gain_l[i];
    }
}







