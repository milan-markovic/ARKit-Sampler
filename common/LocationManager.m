//
//  LocationManager.m
//  ARKit-Sampler
//
//  Created by Milan Markovic on 4/23/18.
//  Copyright © 2018 Shuichi Tsutsumi. All rights reserved.
//

#import "LocationManager.h"

@implementation LocationManager


#pragma mark Singleton Methods

+ (id)sharedManager {
    static LocationManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        [[GamificationManager sharedManager] registerInputObserver:self];
    }
    return self;
}


#pragma mark - GamificationTracker methods

-(int32_t) getInputEventsCountForLocation:(CLLocation*) location withRadius:(int32_t) radius {
    return 0;
}

#pragma mark - InputEventObserver methods

- (void) onInputEvent:(NSUUID*) eventId type:(GamificationInputType)inputType{
    
}

@end
