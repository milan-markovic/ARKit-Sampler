//
//  GamificationManager.m
//  ARKit-Sampler
//
//  Created by Milan Markovic on 4/23/18.
//  Copyright © 2018 Shuichi Tsutsumi. All rights reserved.
//

#import "GamificationManager.h"
#import "LocationManager.h"

//treshold for using planes
const int32_t GAMIFICATION_INPUT_TIME_TRESHOLD_1 = 10000; //10s

//treshold for using floating positions
const int32_t GAMIFICATION_INPUT_TIME_TRESHOLD_2 = 20000; //20s

//threshold for something else
const int32_t GAMIFICATION_INPUT_TIME_TRESHOLD_3 = 30000; //30s

//threshold for location radius
const int32_t GAMIFICATION_INPUT_LOCATION_TRESHOLD = 5;

//location radius
const int32_t GAMIFICATION_RADIUS = 20; //m

typedef enum : NSUInteger {
    INPUT_TYPE_USE_PLANES,
    INPUT_TYPE_USE_FLOAT,
    INPUT_TYPE_USE_ANY,
    INPUT_TYPE_NONE
} GamificationInputType;

@implementation GamificationManager {
    
    
    int32_t timeSinceLastGamificationEvent;

}


#pragma mark Singleton Methods

+ (id)sharedManager {
    static GamificationManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        timeSinceLastGamificationEvent = 0;
    }
    return self;
}


#pragma mark - Public methods

-(void) handleUpdate:(id<SCNSceneRenderer>)renderer withNodes:(NSDictionary<NSUUID*, NSDictionary*>*) nodes {
    ARSCNView* sceneView = (ARSCNView*) renderer;

    GamificationInputType inputType = [self getInputEventType];
    
    switch (inputType) {
        case INPUT_TYPE_USE_PLANES:
            [self addGamificationInput:sceneView forNodes:nodes];
            break;
        case INPUT_TYPE_USE_FLOAT:
            [self addGamificationInput:sceneView forVector:SCNVector3Zero];
            
        default:
            break;
    }
    
}

#pragma mark - Private methods

-(void) addGamificationInput:(id<SCNSceneRenderer>)renderer forNodes:(NSDictionary<NSUUID*, NSDictionary*>*) nodes{
    
}

-(void) addGamificationInput:(id<SCNSceneRenderer>)renderer forVector:(SCNVector3)vector{
    if(SCNVector3EqualToVector3(SCNVector3Zero, vector)){
        //find random location
    } else {
        
    }
}



-(GamificationInputType) getInputEventType {
    GamificationInputType type;
    
    //time-based
    if(timeSinceLastGamificationEvent < GAMIFICATION_INPUT_TIME_TRESHOLD_1){
        type = INPUT_TYPE_USE_PLANES;
    } else if(timeSinceLastGamificationEvent < GAMIFICATION_INPUT_TIME_TRESHOLD_2){
        type = INPUT_TYPE_USE_FLOAT;
    } else if(timeSinceLastGamificationEvent < GAMIFICATION_INPUT_TIME_TRESHOLD_3){
        type = INPUT_TYPE_USE_ANY;
    } else {
        type = INPUT_TYPE_NONE;
    }
    
    //location-based
    CLLocation* location = [[LocationManager sharedManager] getLocation];
    
    int32_t events = [[LocationManager sharedManager] getInputEventsCountForLocation:location withRadius:GAMIFICATION_RADIUS];
    if(events > GAMIFICATION_INPUT_LOCATION_TRESHOLD){
        type = INPUT_TYPE_NONE;
    }
    
    return type;
}

@end
