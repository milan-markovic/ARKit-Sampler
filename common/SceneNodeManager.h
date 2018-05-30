//
//  PlaneManager.h
//  ARKit-Sampler
//
//  Created by Milan Markovic on 4/12/18.
//  Copyright © 2018 Shuichi Tsutsumi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ARKit/ARKit.h>
#import <UIKit/UIKit.h>
@import SceneKit;

@interface SceneNodeManager : NSObject<ARSCNViewDelegate, ARSessionDelegate>

+ (SceneNodeManager*)sharedManager;

@property ARSCNView* sceneView;


@end
