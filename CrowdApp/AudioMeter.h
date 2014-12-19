//
//  AudioMeter.h
//  CrowdApp
//
//  Created by Daniel Andersen on 19/12/14.
//
//

#import <Foundation/Foundation.h>

@interface AudioMeter : NSObject

- (instancetype)initWithSamplePeriod:(NSTimeInterval)samplePeriod;
- (void)beginAudioMeteringWithCallback:(void (^)(double value))callback;
- (void)endAudioMetering;

@end
