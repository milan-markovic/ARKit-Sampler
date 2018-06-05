//
//  GamificationAnchorRepository.m
//  ARKit-Sampler
//
//  Created by Milan Markovic on 6/5/18.
//  Copyright © 2018 Shuichi Tsutsumi. All rights reserved.
//


#import "GamificationAnchorRepository.h"
#import "GamificationDataRepository.h"

@implementation GamificationAnchorEntry

@synthesize node;
@synthesize planeAnchor;

-(instancetype) initWithNode:(SCNNode*)_node andAnchor:(ARPlaneAnchor*)_planeAnchor{
    if(self = [super init]){
        node = _node;
        planeAnchor = _planeAnchor;
    }
    return self;
}


-(SCNVector3) getSCNVector3Location{
    matrix_float4x4 planeMatrix = [self.planeAnchor transform];
    SCNMatrix4 sceneMatrix = SCNMatrix4FromMat4(planeMatrix);
    return SCNVector3Make(sceneMatrix.m41, sceneMatrix.m42, sceneMatrix.m43);
}

@end


static NSMutableDictionary<NSUUID*, GamificationAnchorEntry*>* nodes;


@implementation GamificationAnchorRepository


+(void) initialize{
    nodes = [[NSMutableDictionary alloc] init];
}

+(void) setNode:(SCNNode*)node andAnchor:(ARPlaneAnchor*)anchor forKey:(NSUUID*) uuid{
    [nodes setObject:[[GamificationAnchorEntry alloc] initWithNode:node andAnchor:anchor] forKey:uuid];
    
}

+(void) removeNode:(NSUUID*)uuid{
    [nodes removeObjectForKey:uuid];
}

+(GamificationAnchorEntry*) getEntryForIdentifier:(NSUUID*)uuid{
    return [nodes objectForKey:uuid];
}

+(NSUUID*) getAvailableAnchorIdentifier{
    for (NSUUID* uuid in nodes) {
        GamificationDataEntry* data = [GamificationDataRepository getEntryForIdentifier:uuid];
        
        if(data.gamified == 0){
            return uuid;
        }
    }
    return nil;
}



@end
