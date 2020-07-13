

#import "AudioEngine.h"
#import <AudioToolbox/AudioToolbox.h>



AudioEngine* audioEngine;

AURenderCallbackStruct callbackStruct;
//AudioUnit au;
AudioBuffer tempBuffer;

//Structure to hold the audio data. Use only this structure to pass the Audio Data.
// Structure is defined in Audio Buffer.

audioData audio = {FRAME_SIZE, new Float32[audio.frameSize],new Float32[audio.frameSize]};

static void deInterleave(AudioBuffer *someData, audioData *audio ,UInt32 inNumberFrames)
{
    // As number of channel are two, Data is interleaved. Since Microphone is not stereo,
    //we can just take Alternate samples and put into out left channel. In Recording left and right channel are equal.
    
    
        for(int sampleIdx = 0; sampleIdx < inNumberFrames; ++sampleIdx)
        {
            Float32 *sampleBuffer = (Float32*) someData->mData;
            audio->left[sampleIdx] = sampleBuffer[2*sampleIdx];
            audio->right[sampleIdx] = sampleBuffer[2*sampleIdx];
        }
    
    
    return;
}


static void reInterleave(AudioBuffer *someData, audioData *audio,UInt32 inNumberFrames)
{
    
    // Put left and right channel back.
   
        for(int sampleIdx = 0; sampleIdx < inNumberFrames; ++sampleIdx) {
            Float32 *sampleBuffer = (Float32*) someData->mData;
            sampleBuffer[2*sampleIdx] = audio->left[sampleIdx];
            sampleBuffer[2*sampleIdx+1] = audio->right[sampleIdx];
        }

    return;
    
}



struct CallbackData{
    
    AudioUnit               rioUnit;
    DCRejectionFilter*      dcRejectionFilter;
    BOOL*                   muteAudio;
    BOOL*                   audioChainIsBeingReconstructed;
    
    
    CallbackData(): rioUnit(NULL), muteAudio(NULL), audioChainIsBeingReconstructed(NULL) {}
    
}cd;


// Output callback


static OSStatus playbackCallback(void *inRefCon,AudioUnitRenderActionFlags *ioActionFlags,const AudioTimeStamp *inTimeStamp,UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData)
{
    
    // Notes: ioData contains buffers (may be more than one!)
    // Fill them up as much as you can. Remember to set the size value in each buffer to match how
    // much data is in the buffer.
    for (int i=0; i < ioData->mNumberBuffers; i++) {
        AudioBuffer buffer = ioData->mBuffers[i];
        UInt32 size = min(buffer.mDataByteSize, tempBuffer.mDataByteSize);
        memcpy(buffer.mData, tempBuffer.mData, size);
        buffer.mDataByteSize = size;
    }
    
    return noErr;
}

// Recording callback
static OSStatus recordingCallback(void *inRefCon,AudioUnitRenderActionFlags *ioActionFlags,const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData)
{
    
    AudioBuffer buffer;
    
    
    buffer.mNumberChannels = kNumberOfChannel;
    buffer.mDataByteSize = inNumberFrames * 4 * kNumberOfChannel;
    buffer.mData = malloc( inNumberFrames * 4 * kNumberOfChannel );
    
    // Put buffer in a AudioBufferList
    
    AudioBufferList bufferList;
    bufferList.mNumberBuffers = 1;
    bufferList.mBuffers[0] = buffer;
    
    AudioUnitRender(cd.rioUnit, ioActionFlags, inTimeStamp,inBusNumber,inNumberFrames,&bufferList);
    
    [audioEngine processAudio:&bufferList];
    
    // printf("%f\n",buffer);
    free(bufferList.mBuffers[0].mData);
    return noErr;
}



@implementation AudioEngine

- (id)init
{
    if (self = [super init])
        [self setupAudioChain];
    
    return self;
}


-(void) setupAudioSession
{
    NSError* theError = nil;
    BOOL result = YES;
    // Configure the AudioSession
    
    AVAudioSession *sessionInstance = [AVAudioSession sharedInstance];
    [sessionInstance setCategory:AVAudioSessionCategoryPlayAndRecord
                     withOptions: AVAudioSessionCategoryOptionAllowBluetoothA2DP | AVAudioSessionCategoryOptionAllowAirPlay
                           error:NULL];  ///Play and Record
    [sessionInstance setPreferredSampleRate:SAMPLING_FREQUENCY error:NULL];
    [sessionInstance setPreferredIOBufferDuration:(float)FRAME_SIZE/SAMPLING_FREQUENCY error:NULL];
    
    
    NSArray* inputs = [sessionInstance availableInputs];
    
    // Locate the Port corresponding to the built-in microphone.
    AVAudioSessionPortDescription* builtInMicPort = nil;
    for (AVAudioSessionPortDescription* port in inputs)
    {
        if ([port.portType isEqualToString:AVAudioSessionPortBuiltInMic])
        {
            builtInMicPort = port;
            break;
        }
    }
    
    theError = nil;
    result = [sessionInstance setPreferredInput:builtInMicPort error:&theError];
    if (!result)
    {
        // an error occurred. Handle it!
        NSLog(@"setPreferredInput failed");
    }
    
    // Set the session Active.
    [[AVAudioSession sharedInstance] setActive:YES error:NULL];
    
    
    return;
    
    
}


-(void) setupIOunit
{
    // Create a new instance of AURemoteIO
    
    AudioComponentDescription desc;
    desc.componentType = kAudioUnitType_Output;
    desc.componentSubType = kAudioUnitSubType_RemoteIO;
    desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    desc.componentFlags = 0;
    desc.componentFlagsMask = 0;
    
    
    AudioComponent comp = AudioComponentFindNext(NULL, &desc);
    if (AudioComponentInstanceNew(comp, &_rioUnit) != 0) abort();
    
    //  Enable input and output on AURemoteIO
    //  Input is enabled on the input scope of the input element
    //  Output is enabled on the output scope of the output element
    
    UInt32 one = 1;
    
    if (AudioUnitSetProperty(_rioUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input, 1, &one, sizeof(one))) abort();
    if (AudioUnitSetProperty(_rioUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Output, 0, &one, sizeof(one))) abort();
    
    AudioStreamBasicDescription format = [self LPCMFormatDescription];
    
    //set the input and output format explicitly
    
    if (AudioUnitSetProperty(_rioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &format,
                             sizeof(format))) abort();
    if (AudioUnitSetProperty(_rioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 1, &format,
                             sizeof(format))) abort();
    
    
    
    // Set the MaximumFramesPerSlice property. This property is used to describe to an audio unit the maximum number
    // of samples it will be asked to produce on any single given call to AudioUnitRender
    UInt32 maxFramesPerSlice = 4096;
    AudioUnitSetProperty(_rioUnit, kAudioUnitProperty_MaximumFramesPerSlice, kAudioUnitScope_Global, 0, &maxFramesPerSlice, sizeof(UInt32));
    
    // Get the property value back from AURemoteIO. We are going to use this value to allocate buffers accordingly
    UInt32 propSize = sizeof(UInt32);
    AudioUnitGetProperty(_rioUnit, kAudioUnitProperty_MaximumFramesPerSlice, kAudioUnitScope_Global, 0, &maxFramesPerSlice, &propSize);
    
    
    _dcRejectionFilter = new DCRejectionFilter;
    
    // We need references to certain data in the render callback
    // This simple struct is used to hold that information
    
    cd.rioUnit = _rioUnit;
    cd.dcRejectionFilter = _dcRejectionFilter;
    cd.audioChainIsBeingReconstructed = &_audioChainIsBeingReconstructed;
    
    
    callbackStruct.inputProc = recordingCallback;
    callbackStruct.inputProcRefCon = NULL;
    AudioUnitSetProperty(_rioUnit, kAudioOutputUnitProperty_SetInputCallback, kAudioUnitScope_Global, kInputBus,  &callbackStruct, sizeof(callbackStruct));
    
    // Set output callback
    callbackStruct.inputProc = playbackCallback;
    callbackStruct.inputProcRefCon = NULL;
    AudioUnitSetProperty(_rioUnit, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Global, kOutputBus,&callbackStruct, sizeof(callbackStruct));
    tempBuffer.mNumberChannels = format.mChannelsPerFrame;
    tempBuffer.mDataByteSize = FRAME_SIZE * format.mBytesPerFrame;
    tempBuffer.mData = malloc( FRAME_SIZE * format.mBytesPerFrame );
   
    // Initialize the AURemoteIO instance
    AudioUnitInitialize(_rioUnit);
    AudioOutputUnitStart(_rioUnit);
    
    return;
}


- (AudioStreamBasicDescription)LPCMFormatDescription {
    
    AudioStreamBasicDescription format;
    UInt32 sampleSize = 4;
    UInt32 numberOfChannels = kNumberOfChannel;
    format.mSampleRate = SAMPLING_FREQUENCY;
    format.mFormatID = kAudioFormatLinearPCM;
    //  format.mFormatFlags = kAudioFormatFlagIsSignedInteger;
    format.mFormatFlags       =  kAudioFormatFlagIsPacked | kAudioFormatFlagIsFloat;
    format.mFramesPerPacket = 1;
    format.mChannelsPerFrame = numberOfChannels;
    format.mBitsPerChannel = 8*sampleSize;
    format.mBytesPerPacket = sampleSize*numberOfChannels;
    format.mBytesPerFrame = sampleSize*numberOfChannels;
    return format;
}

- (void)setupAudioChain
{
    [self setupAudioSession];
    [self setupIOunit];
}


-(OSStatus)startIOUnit
{
    OSStatus err = AudioOutputUnitStart(_rioUnit);
    if (err) NSLog(@"couldn't start AURemoteIO: %d", (int)err);
    return err;
    
}

-(OSStatus)stopIOUnit
{
    OSStatus err = AudioOutputUnitStop(_rioUnit);
    if (err) NSLog(@"couldn't stop AURemoteIO: %d", (int)err);
    return err;
    
}

/**
 Change this funtion to decide what is done with incoming
 audio data from the microphone.
 Right now we copy it to our own temporary buffer.
 */
- (void) processAudio: (AudioBufferList*) bufferList {
    AudioBuffer sourceBuffer = bufferList->mBuffers[0];
   
    
    
    // printf("%f \n", elapsedTime);
   // if (sourceBuffer.mDataByteSize < FRAME_SIZE*8){
        //printf("%d \n", inNumberFrames);
        
        
        //  memset(bufferList->mBuffers[0].mData, 0, bufferList->mBuffers[0].mDataByteSize);
  //  }
    
    
    // fix tempBuffer size if it's the wrong size
    if (tempBuffer.mDataByteSize != sourceBuffer.mDataByteSize) {
        free(tempBuffer.mData);
        tempBuffer.mDataByteSize = sourceBuffer.mDataByteSize;
        tempBuffer.mData = malloc(sourceBuffer.mDataByteSize);
    }
    
    // copy incoming audio data to temporary buffer
    memcpy(tempBuffer.mData, bufferList->mBuffers[0].mData, bufferList->mBuffers[0].mDataByteSize);
}

/**
 Clean up.
 */
- (void) dealloc {
    //[super  dealloc];
    AudioUnitUninitialize(_rioUnit);
    free(tempBuffer.mData);
}





@end









