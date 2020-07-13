//
//  overlapAdd.cpp
//  frameOverlap
//
//  Created by Shankar, Nikhil on 8/28/19.
//  Copyright © 2019 default. All rights reserved.
//

#include "overlapAdd.hpp"
#include <math.h>

void overlapAdd::init()
{
    in_prev = new float [frameS];
    outputOld = new float [frameS];
    win = new float [frameS*2];
    invWin = new float [frameS];
    inputBuffer = new float [frameS*2];
    xReal1 = new float [nFFT];
    xImag1 = new float [nFFT];
    yReal = new float [nFFT];
    yImag = new float [nFFT];
    xReal2 = new float [nFFT];
    xImag2 = new float [nFFT];
    cosine = new float [nFFT/2];
    sine = new float [nFFT];
    sum_win =0;
    for(int i=0;i<frameS;++i)
    {
        in_prev[i]=0;
        outputOld[i]=0;
    }
    for(int i=0;i<nFFT/2;++i)
    {
        cosine[i]=0;
        sine[i]=0;
    }
    for (int i = 0; i < (frameS*2); i++)
    {
        win[i] = 0.5 * (1 - cosf(2 * M_PI*(i + 1) / ((frameS*2) + 1)));
        sum_win += win[i];
    }
    for (int i = 0; i < (frameS*2); i++)
    {
        win[i] = (win[i]*frameS)/sum_win;
    }
    for (int i = 0; i < frameS; i++)
    {
        invWin[i] = 1 / (win[i] + win[i + frameS]);
    }
}

overlapAdd::~overlapAdd()
{
    delete [] in_prev;
    delete [] inputBuffer;
    delete [] win;
    delete [] xReal1;
    delete [] xImag1;
    delete [] xReal2;
    delete [] xImag2;
    delete [] yReal;
    delete [] yImag;
    delete [] outputOld;
    delete [] invWin;
}

void overlapAdd::process(const float *input, float *output, const int frameCount)
{
    for(int i=0;i<frameS;++i)
    {
        inputBuffer[i] = in_prev[i];
        in_prev[i]=input[i];
        inputBuffer[i+frameS] = input[i];
    }
    for(int i=0;i<frameS*2;++i)
    {
        inputBuffer[i] = inputBuffer[i]*win[i];
        printf("%.32lf\n",inputBuffer[i]);
    }
    FFT(inputBuffer,xReal1,xImag1,nFFT);
    IFFT(xReal1, xImag1, yReal, yImag, nFFT);
    for(int i=0; i<frameS; i++)
    {
        output[i]=(outputOld[i]+yReal[i])*invWin[i];
        outputOld[i]=yReal[i+nFFT/2];
    }
    
}

void overlapAdd::FFT(const float* input, float *outputReal, float *outputImag, const int nFFT)
{
    float arg;
    for (int i = 0; i<nFFT / 2; i++)
    {
        arg = -2 * M_PI*i / nFFT;
        cosine[i] = cos(arg);
        sine[i] = sin(arg);
    }
    int i, j, k, L, m, n, o, p, q;
    float tempReal, tempImaginary, cos, sin, xt, yt;
    k = nFFT;
    for (i = 0; i<k; i++)
    {
        outputReal[i] = input[i];
        outputImag[i] = 0;
    }
    
    j = 0;
    m = k / 2;
    //bit reversal
    for (i = 1; i<(k - 1); i++)
    {
        L = m;
        //L = pow(2,ceil(log2(m)));
        while (j >= L)
        {
            j = j - L;
            L = L / 2;
        }
        j = j + L;
        if (i<j)
        {
            tempReal = outputReal[i];
            tempImaginary = outputImag[i];
            outputReal[i] = outputReal[j];
            outputImag[i] = outputImag[j];
            outputReal[j] = tempReal;
            outputImag[j] = tempImaginary;
        }
    }
    L = 0;
    m = 1;
    n = k / 2;
    //computation
    for (i = k; i>1; i = (i >> 1))
    {
        L = m;
        m = 2 * m;
        o = 0;
        for (j = 0; j<L; j++)
        {
            cos = cosine[o];
            sin = sine[o];
            o = o + n;
            for (p = j; p<k; p = p + m)
            {
                q = p + L;
                xt = cos*outputReal[q] - sin*outputImag[q];
                yt = sin*outputReal[q] + cos*outputImag[q];
                outputReal[q] = (outputReal[p] - xt);
                outputImag[q] = (outputImag[p] - yt);
                outputReal[p] = (outputReal[p] + xt);
                outputImag[p] = (outputImag[p] + yt);
            }
        }
        n = n >> 1;
    }
}

void overlapAdd::IFFT(const float* inputReal, const float* inputImag, float *outputReal, float *outputImag, const int nFFT)
{
    float arg;
    for (int i = 0; i<nFFT / 2; i++)
    {
        arg = -2 * M_PI*i / nFFT;
        cosine[i] = cos(arg);
        sine[i] = sin(arg);
    }
    int i, j, k, L, m, n, o, p, q;
    float tempReal, tempImaginary, cos, sin, xt, yt;
    k = nFFT;
    for (i = 0; i<k; i++)
    {
        outputReal[i] = inputReal[i];
        outputImag[i] = (-1)*inputImag[i];
    }
    
    j = 0;
    m = k / 2;
    //bit reversal
    for (i = 1; i<(k - 1); i++)
    {
        L = m;
        while (j >= L)
        {
            j = j - L;
            L = L / 2;
        }
        j = j + L;
        if (i<j)
        {
            tempReal = outputReal[i];
            tempImaginary = outputImag[i];
            outputReal[i] = outputReal[j];
            outputImag[i] = outputImag[j];
            outputReal[j] = tempReal;
            outputImag[j] = tempImaginary;
        }
    }
    L = 0;
    m = 1;
    n = k / 2;
    //computation
    for (i = k; i>1; i = (i >> 1))
    {
        L = m;
        m = 2 * m;
        o = 0;
        for (j = 0; j<L; j++)
        {
            cos = cosine[o];
            sin = sine[o];
            o = o + n;
            for (p = j; p<k; p = p + m)
            {
                q = p + L;
                xt = cos*outputReal[q] - sin*outputImag[q];
                yt = sin*outputReal[q] + cos*outputImag[q];
                outputReal[q] = (outputReal[p] - xt);
                outputImag[q] = (outputImag[p] - yt);
                outputReal[p] = (outputReal[p] + xt);
                outputImag[p] = (outputImag[p] + yt);
            }
        }
        n = n >> 1;
    }
    for (i = 0; i<k; i++)
    {
        outputReal[i] = outputReal[i] / k;
        outputImag[i] = outputImag[i] / k;
    }
}
