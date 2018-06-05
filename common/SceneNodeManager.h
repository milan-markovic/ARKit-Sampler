//
//  PlaneManager.h
//  ARKit-Sampler
//
//  Created by Milan Markovic on 4/12/18.
//  Copyright © 2018 Shuichi Tsutsumi. All rights reserved.
//

#ifndef scene_node_manager_h
#define scene_node_manager_h

#import <Foundation/Foundation.h>
#import <ARKit/ARKit.h>
#import <UIKit/UIKit.h>
@import SceneKit;
#import "InputEventObserver.h"
#import "OutputEventObserver.h"

@interface SceneNodeManager : NSObject<ARSCNViewDelegate, ARSessionDelegate, InputEventObserver, OutputEventObserver>

+ (SceneNodeManager*)sharedManager;

@property ARSCNView* sceneView;

-(void) onInputEvent:(NSUUID*) eventId type:(GamificationInputType)inputType;
-(void) touchesBegan:(NSSet<UITouch*>*)touches with:(UIEvent*) event;

-(void) registerEventObjectObserver:(id<EventObjectObserver>) observer;

@end

#endif
