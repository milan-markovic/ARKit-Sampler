//
//  GamificationManager.h
//  ARKit-Sampler
//
//  Created by Milan Markovic on 4/23/18.
//  Copyright © 2018 Shuichi Tsutsumi. All rights reserved.
//

#import <Foundation/Foundation.h>
@import ARKit;

typedef enum : NSUInteger {
    INPUT_TYPE_USE_PLANES,
    INPUT_TYPE_USE_AIR,
    INPUT_TYPE_USE_ANY,
    INPUT_TYPE_NONE
} GamificationInputType;


@interface GamificationManager : NSObject

+ (GamificationManager*)sharedManager;


-(GamificationInputType) handleUpdate;
@end
