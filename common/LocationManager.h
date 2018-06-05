//
//  LocationManager.h
//  ARKit-Sampler
//
//  Created by Milan Markovic on 4/23/18.
//  Copyright © 2018 Shuichi Tsutsumi. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;
#import "GamificationTracker.h"
#import "InputEventObserver.h"

@interface LocationManager : NSObject<GamificationTracker, InputEventObserver>

+(LocationManager*) sharedManager;

-(CLLocation*) getLocation;

-(int32_t) getInputEventsCountForLocation:(CLLocation*) location withRadius:(int32_t) radius;

-(void) onInputEvent:(NSUUID*) eventId type:(GamificationInputType)inputType;

@end
