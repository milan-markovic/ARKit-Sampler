//
//  GamificationManager.h
//  ARKit-Sampler
//
//  Created by Milan Markovic on 4/23/18.
//  Copyright © 2018 Shuichi Tsutsumi. All rights reserved.
//

#import <Foundation/Foundation.h>
@import ARKit;


extern const int32_t FEATURE_POINTS_COUNT_TRESHOLD;

extern const int32_t SCENE_UPDATE_INTERVAL;

@protocol InputEventObserver;
@protocol OutputEventObserver;
#import "EventObjectObserver.h"

typedef enum : NSUInteger {
    INPUT_TYPE_USE_PLANES,
    INPUT_TYPE_USE_AIR,
    INPUT_TYPE_USE_ANY,
    INPUT_TYPE_NONE
} GamificationInputType;


@interface GamificationManager : NSObject<EventObjectObserver>

+ (GamificationManager*)sharedManager;


-(GamificationInputType) handleUpdate;
-(void) registerInputObserver:(id<InputEventObserver>) observer;
-(void) registerOutputObserver:(id<OutputEventObserver>) observer;

@end
