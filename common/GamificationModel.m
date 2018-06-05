//
//  GamificationModel.m
//  ARKit-Sampler
//
//  Created by Milan Markovic on 6/5/18.
//  Copyright © 2018 Shuichi Tsutsumi. All rights reserved.
//

#import "GamificationModel.h"

static SCNSceneSource* sceneSource;

@implementation GamificationModel

+ (void)initialize
{
    if (self == [GamificationModel class]) {
        NSURL* sceneUrl = [[NSBundle mainBundle] URLForResource:@"models.scnassets/test1" withExtension:@"dae"];
        sceneSource = [[SCNSceneSource alloc] initWithURL:sceneUrl options:@{SCNSceneSourceAnimationImportPolicyKey : SCNSceneSourceAnimationImportPolicyDoNotPlay}];
    }
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        SCNNode* node = self;
        [node addChildNode:[sceneSource entryWithIdentifier:@"Corona_Botella" withClass:SCNNode.class]];
        
        NSArray* animationKeys = [sceneSource identifiersOfEntriesWithClass:CAAnimation.class];
        CAAnimation* animation = nil;
        for (NSString* key in animationKeys) {
            animation = [sceneSource entryWithIdentifier:key withClass:CAAnimation.class];
        }

        if(animation != nil){
            animation.repeatCount = 100;
            animation.speed = 1;
            animation.removedOnCompletion = false;
            [node addAnimation:animation forKey:@"bottle"];
        }else {
            NSLog(@"animation is nil");
        }
    }
    return self;
}


@end
