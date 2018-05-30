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

@interface LocationManager : NSObject<GamificationTracker>

+(LocationManager*) sharedManager;

-(CLLocation*) getLocation;



-(int32_t) getInputEventsCountForLocation:(CLLocation*) location withRadius:(int32_t) radius;
-(void) trackGamificationInputEvent:(CLLocation *)location;
-(void) trackGamificationOutputEvent:(CLLocation *)location;

@end
