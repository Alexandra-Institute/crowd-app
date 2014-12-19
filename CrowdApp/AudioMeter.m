//
//  AudioMeter.m
//  CrowdApp
//
//  Created by Daniel Andersen on 19/12/14.
//
//

#import "AudioMeter.h"

#import <EZAudio/EZMicrophone.h>

@interface AudioMeter () <EZMicrophoneDelegate>

@property (nonatomic, copy) void (^measurementCallback)(double value);
@property (nonatomic, strong) EZMicrophone *microphone;

@property (nonatomic, weak) NSTimer *timer;
@property (nonatomic, assign) NSTimeInterval period;

@property (nonatomic, assign) double runningSumSquares;
@property (nonatomic, assign) NSUInteger numberSamples;

@property (nonatomic, strong) dispatch_queue_t sampleProcessingQueue;

@end

@implementation AudioMeter

- (instancetype)initWithSamplePeriod:(NSTimeInterval)samplePeriod {
    if (self = [super init]) {
        self.microphone = [EZMicrophone microphoneWithDelegate:self];
        self.period = samplePeriod;
        self.sampleProcessingQueue = dispatch_queue_create("com.shinobicontrols.gauges.soundmeter.processqueue", NULL);
    }
    return self;
}

- (void)beginAudioMeteringWithCallback:(void (^)(double))callback {
    self.measurementCallback = callback;
    
    // Start with sensible values
    self.runningSumSquares = 0;
    self.numberSamples = 0;
    
    [self.microphone startFetchingAudio];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.period
                                                  target:self
                                                selector:@selector(handleTimerFired)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)handleTimerFired {
    // Need the sample processing to happen on the queue
    dispatch_async(self.sampleProcessingQueue, ^{
        // Calculate this period's value and push it back on the main thread
        double mean = self.runningSumSquares / self.numberSamples;
        double rms  = sqrt(mean);
        dispatch_async(dispatch_get_main_queue(), ^{
            // Return the value
            self.measurementCallback(rms);
        });
        // Reset for the next period
        self.runningSumSquares = 0;
        self.numberSamples = 0;
    });
}

#pragma mark - EZMicrophoneDelegate methods
- (void)microphone:(EZMicrophone *)microphone hasAudioReceived:(float **)buffer withBufferSize:(UInt32)bufferSize withNumberOfChannels:(UInt32)numberOfChannels {
    // We'll just use the first channel
    float *dataPoints = buffer[0];
    // Calculate sum of squares
    double sumSquares = 0;
    float *currentDP = dataPoints;
    for (UInt32 i=0; i<bufferSize; i++) {
        sumSquares += *currentDP * *currentDP;
        currentDP++;
    }
    
    // Add it to the running total
    dispatch_async(self.sampleProcessingQueue, ^{
        self.runningSumSquares += sumSquares;
        self.numberSamples += bufferSize;
    });
}

- (void)endAudioMetering {
    [self.timer invalidate];
    self.timer = nil;
    [self.microphone stopFetchingAudio];
}

@end
