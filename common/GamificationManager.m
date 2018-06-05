//
//  GamificationManager.m
//  ARKit-Sampler
//
//  Created by Milan Markovic on 4/23/18.
//  Copyright © 2018 Shuichi Tsutsumi. All rights reserved.
//

#import "GamificationManager.h"
#import "LocationManager.h"
#import "InputEventObserver.h"
#import "SceneNodeManager.h"
#import "GamificationObjectRepository.h"
#import "GamificationDataRepository.h"

//treshold for using planes
const int32_t GAMIFICATION_INPUT_TIME_TRESHOLD_1 = 10; //10s

//treshold for using floating positions
const int32_t GAMIFICATION_INPUT_TIME_TRESHOLD_2 = 20; //20s

//threshold for something else
const int32_t GAMIFICATION_INPUT_TIME_TRESHOLD_3 = 30; //30s

//threshold for location radius
const int32_t GAMIFICATION_INPUT_LOCATION_TRESHOLD = 5;

//location radius
const int32_t GAMIFICATION_RADIUS = 20; //m



@implementation GamificationManager {
    
    
    int32_t timeSinceLastGamificationEvent;
    NSMutableArray<id<InputEventObserver>>* inputObservers;
    NSMutableArray<id<OutputEventObserver>>* outputObservers;

    int32_t spawnedInputs;
    int32_t consumedInputs;
    int32_t activeInputs;
    
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
        inputObservers = [[NSMutableArray alloc] init];
        outputObservers = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - EventObjectObserver methods

-(void)onEventObjectClick:(NSUUID*) eventId{
    [self handleEventObjectClick:eventId];
}


#pragma mark - Public methods

-(GamificationInputType) handleUpdate{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[SceneNodeManager sharedManager] registerEventObjectObserver:self];
    });

    GamificationInputType inputType = [self getInputEventType];
    NSLog(@"Gamification handleUpdate %u", (unsigned)inputType);
    
    NSUUID* eventId = [NSUUID new];
    if(inputType == INPUT_TYPE_NONE){
        eventId = [[NSUUID alloc] initWithUUIDString:@"NONE"];
    }
    [self notifyInputObservers:eventId type:inputType];
    
    if(inputType != INPUT_TYPE_NONE){
        timeSinceLastGamificationEvent = 0;
    } else {
        timeSinceLastGamificationEvent += SCENE_UPDATE_INTERVAL;
    }
    
    
    return inputType;
    
}



-(void) registerInputObserver:(id<InputEventObserver>) observer{
    [inputObservers addObject:observer];
}

-(void) registerOutputObserver:(id<OutputEventObserver>) observer{
    [outputObservers addObject:observer];
}

-(void) notifyInputObservers:(NSUUID*)eventId type:(GamificationInputType) inputType{
    for (id<InputEventObserver> observer in inputObservers) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            @try{
                [observer onInputEvent:eventId type:inputType];
            } @catch(NSException* e){
                NSLog(@"Exception occured in observer: %@" , [e description]);
            }
        });
    }
    
}

-(void) notifyOutputObservers:(NSUUID*)eventId {
    for (id<OutputEventObserver> observer in outputObservers) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            @try{
                [observer onOutputEvent:eventId];
            } @catch(NSException* e){
                NSLog(@"Exception occured in observer: %@" , [e description]);
            } @finally{
                if([outputObservers lastObject] == observer){
                    [GamificationObjectRepository removeGamificationNode:eventId];
                }
            }
        });
    }
}

#pragma mark - Private methods

-(void) handleEventObjectClick:(NSUUID*) uuid{
    [self consumeGamificationEvent:uuid];
    
    [self notifyOutputObservers:uuid];
}

-(void) consumeGamificationEvent:(NSUUID*) uuid{
    //update gamification data
}


-(GamificationInputType) getInputEventType {
    GamificationInputType type;
    
    //time-based
    if(timeSinceLastGamificationEvent > GAMIFICATION_INPUT_TIME_TRESHOLD_1){
        type = INPUT_TYPE_USE_PLANES;
    } else if(timeSinceLastGamificationEvent > GAMIFICATION_INPUT_TIME_TRESHOLD_2){
        type = INPUT_TYPE_USE_AIR;
    } else if(timeSinceLastGamificationEvent > GAMIFICATION_INPUT_TIME_TRESHOLD_3){
        type = INPUT_TYPE_USE_ANY;
    } else {
        type = INPUT_TYPE_NONE;
    }
    
    //location-based
    CLLocation* location = nil;//[[LocationManager sharedManager] getLocation];
    
    int32_t events = [[LocationManager sharedManager] getInputEventsCountForLocation:location withRadius:GAMIFICATION_RADIUS];
    if(events > GAMIFICATION_INPUT_LOCATION_TRESHOLD){
        type = INPUT_TYPE_NONE;
    }
    
    return type;
}

@end
