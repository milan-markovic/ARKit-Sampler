//
//  GamificationObjectRepository.h
//  ARKit-Sampler
//
//  Created by Milan Markovic on 6/1/18.
//  Copyright © 2018 Shuichi Tsutsumi. All rights reserved.
//

#import <Foundation/Foundation.h>
@import SceneKit;

@interface GamificationObjectRepository : NSObject

+(NSDictionary<NSUUID*, SCNNode*>*) getAll;

+(SCNNode*) getGamificationNodeForId:(NSUUID*) uuid;

+(void) setGamificationNode:(SCNNode*) node forId:(NSUUID*)uuid;

+(void) removeGamificationNode:(NSUUID*) uuid;

@end
