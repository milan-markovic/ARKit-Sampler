//
//  GamificationTracker.h
//  ARKit-Sampler
//
//  Created by Milan Markovic on 4/23/18.
//  Copyright © 2018 Shuichi Tsutsumi. All rights reserved.
//

#ifndef GamificationTracker_h
#define GamificationTracker_h

#import "GamificationManager.h"
@import CoreLocation;

@protocol GamificationTracker

-(void) getInputEventsCountForLocation:(CLLocation*) location withRadius:(int32_t) radius;

-(void) trackGamificationInputEvent:(CLLocation*) location;
-(void) trackGamificationOutputEvent:(CLLocation*) location;

@end

#endif /* GamificationTracker_h */

