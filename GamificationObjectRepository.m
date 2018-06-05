//
//  GamificationObjectRepository.m
//  ARKit-Sampler
//
//  Created by Milan Markovic on 6/1/18.
//  Copyright © 2018 Shuichi Tsutsumi. All rights reserved.
//

#import "GamificationObjectRepository.h"

static NSMutableDictionary<NSUUID*, SCNNode*>* gamificationNodes;

@implementation GamificationObjectRepository


+(void) initialize{
    gamificationNodes = [[NSMutableDictionary alloc] init];
}

+(NSDictionary<NSUUID*, SCNNode*>*) getAll{
    @synchronized(gamificationNodes){
        return [gamificationNodes copy];
    }
}

+(SCNNode*) getGamificationNodeForId:(NSUUID*) uuid{
    NSLog(@"getGamificationNodeForId %@", uuid);
    @synchronized(gamificationNodes){
        return [gamificationNodes objectForKey:uuid];
    }
}

+(void) setGamificationNode:(SCNNode*) node forId:(NSUUID*)uuid{
    NSLog(@"setGamificationNode %@", uuid);
    @synchronized(gamificationNodes){
        [gamificationNodes setObject:node forKey:uuid];
    }
}

+(void) removeGamificationNode:(NSUUID*) uuid{
    NSLog(@"removeGamificationNode %@", uuid);
    @synchronized(gamificationNodes){
        [gamificationNodes removeObjectForKey:uuid];
    }
}

@end
