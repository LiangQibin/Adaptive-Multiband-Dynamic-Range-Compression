//
//  spline.cpp
//  Kashapp
//
//  Created by SSPRL on 6/13/19.
//  Copyright © 2019 SSPRL. All rights reserved.
//

#include "spline.h"
#include <stdlib.h>


/*************************************************
 *************CUBIC SPLINE PROGRAM*****************
 *************************************************
 The program asks the user to enter the data-points and then returns the cubic splines equations
 for each interval
 Equation for ith interval being:
 ai(x-xi)^3+bi(x-xi)^2+ci(x-xi)+di*/
#include<stdio.h>
#include<math.h>
/*******
 Function that performs Gauss-Elimination and returns the Upper triangular matrix and solution of equations:
 There are two options to do this in C.
 1. Pass the augmented matrix (a) as the parameter, and calculate and store the upperTriangular(Gauss-Eliminated Matrix) in it.
 2. Use malloc and make the function of pointer type and return the pointer.
 This program uses the first option.
 ********/
void gaussEliminationLS(int m, int n, float** a, float* x) {
    int i, j, k;
    for (i = 0; i < m - 1; i++) {
        /*//Partial Pivoting
         for(k=i+1;k<m;k++){
         //If diagonal element(absolute vallue) is smaller than any of the terms below it
         if(fabs(a[i][i])<fabs(a[k][i])){
         //Swap the rows
         for(j=0;j<n;j++){
         float temp;
         temp=a[i][j];
         a[i][j]=a[k][j];
         a[k][j]=temp;
         }
         }
         }*/
        //Begin Gauss Elimination
        for (k = i + 1; k < m; k++) {
            float  term = a[k][i] / a[i][i];
            for (j = 0; j < n; j++) {
                a[k][j] = a[k][j] - term * a[i][j];
            }
        }
        
    }
    //Begin Back-substitution
    for (i = m - 1; i >= 0; i--) {
        x[i] = a[i][n - 1];
        for (j = i + 1; j < n - 1; j++) {
            x[i] = x[i] - a[i][j] * x[j];
        }
        x[i] = x[i] / a[i][i];
    }
    
    return;
    
}
/********************
 Cubic Spline coefficients calculator
 Function that calculates the values of ai, bi, ci, and di's for the cubic splines:
 ai(x-xi)^3+bi(x-xi)^2+ci(x-xi)+di
 ********************/
//void cSCoeffCalc(int n, float h[n], float sig[n + 1], float y[n + 1], float a[n], float b[n], float c[n], float d[n]) {

void cSCoeffCalc(int n, float* h, float* sig, float* y, float* a, float* b, float* c, float* d) {
    int i;
    for (i = 0; i < n; i++) {
        d[i] = y[i];
        b[i] = sig[i] / 2.0;
        a[i] = (sig[i + 1] - sig[i]) / (h[i] * 6.0);
        c[i] = (y[i + 1] - y[i]) / h[i] - h[i] * (2 * sig[i] + sig[i + 1]) / 6.0;
    }
    
    return;
}
/********************
 Function to generate the tridiagonal augmented matrix
 for cubic spline for equidistant data-points
 Parameters:
 n: no. of data-points
 h: array storing the succesive interval widths
 a: matrix that will hold the generated augmented matrix
 y: array containing the y-axis data-points
 ********************/
void tridiagonalCubicSplineGen(int n, float* h, float** a, float* y) {
    int i;
    for (i = 0; i < n - 1; i++) {
        a[i][i] = 2 * (h[i] + h[i + 1]);
    }
    for (i = 0; i < n - 2; i++) {
        a[i][i + 1] = h[i + 1];
        a[i + 1][i] = h[i + 1];
    }
    for (i = 1; i < n; i++) {
        a[i - 1][n - 1] = (y[i + 1] - y[i]) * 6 / (float)h[i] - (y[i] - y[i - 1]) * 6 / (float)h[i - 1];
    }
    
    return;
}
/**************
 Function that copies the elements of a matrix to another matrix
 Parameters: rows(m),columns(n),matrix1[m][n] , matrix2[m][n]
 *******/
void copyMatrix(int m, int n, float** matrix1, float** matrix2) {
    int i, j;
    for (i = 0; i < m; i++) {
        for (j = 0; j < n; j++) {
            matrix2[i][j] = matrix1[i][j];
        }
    }
    
    return;
}

void getValues(int n, float* x, float* y, float* a, float* b, float* c, float* d, int nfft, float* spl) {
    int j = 0; int i;
    while (j <= n) {
        for (i = x[j]; i < x[j + 1]; i++) {
            spl[i] = a[j] * pow(i - x[j], 3) + b[j] * pow(i - x[j], 2) + c[j] * (i - x[j]) + d[j];
            
        }
        j++;
    }
    
    for (i = 0; i < x[0]; i++)
        spl[i] = y[0];
    
    for (i = x[n]; i < nfft/2; i++)
        spl[i] = y[n];
    
    for(i = nfft/2;i<nfft;i++)
        spl[i] = spl[nfft-i-1];
    
    return;
}

void spline(int n, float* x, float* y, int nfft, float* spl) {
    int i;
    n--;
    
    float* h;  h = (float*)calloc(n, sizeof(float));
    
    for (i = 0; i < n; i++) {
        h[i] = x[i + 1] - x[i];
    }
    float* a;  a = (float*)calloc(n, sizeof(float)); //array to store the ai's
    float* b;  b = (float*)calloc(n, sizeof(float)); //array to store the bi's
    float* c;  c = (float*)calloc(n, sizeof(float)); //array to store the ci's
    float* d;  d = (float*)calloc(n, sizeof(float)); //array to store the di's
    float* sig;  sig = (float*)calloc(n + 1, sizeof(float)); //array to store Si's
    float* sigTemp;  sigTemp = (float*)calloc(n - 1, sizeof(float));//array to store the Si's except S0 and Sn
    sig[0] = 0;
    sig[n] = 0;
    //float tri[n - 1][n]; //matrix to store the tridiagonal system of equations that will solve for Si's
    float** tri;
    tri = (float**)calloc(n - 1, sizeof(float*));
    for (i = 0; i < n - 1; i++)
        tri[i] = (float*)calloc(n, sizeof(float));
    
    
    tridiagonalCubicSplineGen(n, h, tri, y); //to initialize tri[n-1][n]
    //printf("The tridiagonal system for the Natural spline is:\n\n");
    //printMatrix(n - 1, n, tri);
    //Perform Gauss Elimination
    gaussEliminationLS(n - 1, n, tri, sigTemp);
    for (i = 1; i < n; i++) {
        sig[i] = sigTemp[i - 1];
    }
    
    //calculate the values of ai's, bi's, ci's, and di's
    cSCoeffCalc(n, h, sig, y, a, b, c, d);
    
    
    getValues(n, x, y, a, b, c, d, nfft, spl);  // computes the values of interpolation and stores it into spl array.
    
    return;
    
    
}
