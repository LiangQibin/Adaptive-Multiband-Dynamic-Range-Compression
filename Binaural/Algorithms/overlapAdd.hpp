//
//  overlapAdd.hpp
//  frameOverlap
//
//  Created by Shankar, Nikhil on 8/28/19.
//  Copyright © 2019 default. All rights reserved.
//

#ifndef overlapAdd_hpp
#define overlapAdd_hpp

#include <stdio.h>

class overlapAdd
{
public:
    void init();
    ~overlapAdd();
    void process(const float *input, float *output, const int frameCount);
    void FFT(const float* input, float *outputReal, float *outputImag, const int nFFT);
    void IFFT(const float* inputReal, const float* inputImag, float *outputReal, float *outputImag, const int nFFT);
    void setFrameSize(int frameSize){frameS = frameSize;}
    void setFftSize(int fftSize){nFFT = fftSize;}
private:
    float *in_prev;
    float *inputBuffer;
    int frameS;
    int nFFT;
    float *win, *invWin;
    float *xReal1, *xImag1, *yReal, *yImag;
    float *xReal2, *xImag2;
    float *cosine, *sine;
    float *outputOld;
    float sum_win;
};
#endif /* overlapAdd_hpp */
