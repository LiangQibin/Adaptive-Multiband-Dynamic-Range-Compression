//
//  Configuration.h
//  Binaural
//
//  Created by Kashyap Patel on 9/24/19.
//  Copyright © 2019 Kashyap Patel. All rights reserved.
//

#ifndef Configuration_h
#define Configuration_h
#include <MacTypes.h>
#include <iostream>
using std::cout;
using std::cin;
using std::endl;

class Configuration{
    
    static Configuration* _instance;
   
    
    bool _isCompressionOn;
    bool _isStereo;
    bool _isAdaptive;
       
    int* _audiogramLeft;
    int* _audiogramRight;
       
       
    float _ratio;
    float _threshold;
    int _numberofChannels;
    float _releaseTime;   //( in ms)
    float _attackTime;    //(in ms)
    int _method;
   
    Configuration(){
       
        _isCompressionOn = true;
        _isStereo = true;
        _isAdaptive = true;
        
        _audiogramLeft = (int*)calloc(9, sizeof(int));
        _audiogramRight = (int*)calloc(9,sizeof(int));
        
        //_audiogramLeft = {0,0,0,0,0,0,0,0,0}
    
        _ratio = 2.0;
        _threshold = 65;     // In dB
        _numberofChannels = 9;
        _releaseTime = 200;   // In
        _attackTime = 20;
        _method = 1;
    }
    
public:
    static Configuration* getInstance(){
        if(_instance == NULL)
            _instance = new Configuration();
        return _instance;
    }

    
    void setAudiogramLeft(int* Left){
        for(int i=0;i<9;i++)
            _audiogramLeft[i] = Left[i];} //// Make a loop
    void setAudiogramRight(int* Right){
        for(int i=0;i<9;i++)
            _audiogramRight[i] = Right[i];}
    void setIsAdaptive(bool ans){_isAdaptive = ans;}
    void setIsCompressionOn(bool ans){_isCompressionOn = ans;}
    void setIsStereo(bool ans){_isStereo = ans;}
    void setRatio(float r){_ratio = r;}
    void setThreshold(float t){_threshold = t;}
    void setNumberofChannels(int n){_numberofChannels = n;}
    void setReleaseTime(float rt){_releaseTime = rt;}
    void setAttackTime(float at){_attackTime = at;}
    void setMethod(int m){_method = m;}
    

    
    bool getIsCompressionOn(){return _isCompressionOn;}
    bool getIsStereo(){return _isStereo;}
    bool getIsAdaptive(){return _isAdaptive;}
    int* getAudiogramLeft(){return _audiogramLeft;}
    int* getAudiogramRight(){return _audiogramRight;}
    float getRatio(){return _ratio;}
    float getThreshold(){return _threshold;}
    int getNumberofChannel(){return _numberofChannels;}
    float getRleaseTime(){return _releaseTime;}
    float getAttackTime(){return _attackTime;}
    float getMethod(){return _method;}
    
    
    void displaySetting(){
     
        cout << "Compression is : " << _isCompressionOn << endl;
        cout << "Stereo is : " << _isStereo << endl;
        cout << "Adaptive is : " << _isAdaptive << endl;
        
        for (int i=0;i<9;i++){
            cout << "Left Audiogram : " << _audiogramLeft[i] << endl;
        }
        for (int i=0;i<9;i++){
            cout << "Right Audiogram : " << _audiogramRight[i] << endl;
        }
        cout << "Ratio is : " << _ratio << endl;
        cout << "Threshold is : " << _threshold << endl;
        cout << "Number of Channel is : " << _numberofChannels << endl;
        cout << "Release Time is : " << _releaseTime << endl;
        cout << "Attack Time is : " << _attackTime << endl;
        cout << "Gain setting method is : " << _method << endl;
        
    }
    
};


#endif /* Configuration_h */
