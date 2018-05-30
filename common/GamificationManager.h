//
//  GamificationManager.h
//  ARKit-Sampler
//
//  Created by Milan Markovic on 4/23/18.
//  Copyright © 2018 Shuichi Tsutsumi. All rights reserved.
//

#import <Foundation/Foundation.h>
@import ARKit;

@interface GamificationManager : NSObject

+ (GamificationManager*)sharedManager;


-(void) handleUpdate:(id<SCNSceneRenderer>)renderer withNodes:(NSDictionary<NSUUID*, NSDictionary*>*) nodes;
@end
