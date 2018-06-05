//
//  InputEventObserver.h
//  ARKit-Sampler
//
//  Created by Milan Markovic on 5/31/18.
//  Copyright © 2018 Shuichi Tsutsumi. All rights reserved.
//
#import "GamificationManager.h"

@protocol InputEventObserver

-(void) onInputEvent:(NSUUID*) eventId type:(GamificationInputType) inputType;

@end
