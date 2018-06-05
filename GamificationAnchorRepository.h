//
//  GamificationAnchorRepository.h
//  ARKit-Sampler
//
//  Created by Milan Markovic on 6/5/18.
//  Copyright © 2018 Shuichi Tsutsumi. All rights reserved.
//

#import <Foundation/Foundation.h>
@import SceneKit;
@import ARKit;


@interface GamificationAnchorEntry : NSObject

-(instancetype) initWithNode:(SCNNode*)node andAnchor:(ARPlaneAnchor*)planeAnchor;
-(SCNVector3) getSCNVector3Location;

@property(readonly) SCNNode* node;
@property(readonly) ARPlaneAnchor* planeAnchor;

@end



@interface GamificationAnchorRepository : NSObject


+(void) setNode:(SCNNode*)node andAnchor:(ARPlaneAnchor*)anchor forKey:(NSUUID*) uuid;

+(void) removeNode:(NSUUID*)uuid;

+(GamificationAnchorEntry*) getEntryForIdentifier:(NSUUID*)uuid;

+(NSUUID*) getAvailableAnchorIdentifier;
    
@end

