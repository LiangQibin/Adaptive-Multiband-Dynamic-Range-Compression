//
//  spline.hpp
//  Kashapp
//
//  Created by SSPRL on 6/13/19.
//  Copyright © 2019 SSPRL. All rights reserved.
//

#ifndef spline_h
#define spline_h

#include <stdio.h>


void gaussEliminationLS(int m, int n, float** a, float* x);
void cSCoeffCalc(int n, float* h, float* sig, float* y, float* a, float* b, float* c, float* d);
void tridiagonalCubicSplineGen(int n, float* h, float** a, float* y);
void copyMatrix(int m, int n, float** matrix1, float** matrix2);
void getValues(int n, float* x, float* y, float* a, float* b, float* c, float* d, int nfft, float* spl);
void spline(int n, float* x, float* y, int nfft, float* spl);

#endif /* spline_hpp */
