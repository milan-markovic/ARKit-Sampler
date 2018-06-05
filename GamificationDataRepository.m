//
//  GamificationDataRepository.m
//  ARKit-Sampler
//
//  Created by Milan Markovic on 6/1/18.
//  Copyright © 2018 Shuichi Tsutsumi. All rights reserved.
//

#import "GamificationDataRepository.h"


@implementation GamificationDataEntry


@synthesize gamified;

@end


NSMutableDictionary<NSUUID*, GamificationDataEntry*>* data;

@implementation GamificationDataRepository

+(void) initialize{
    data = [[NSMutableDictionary alloc] init];
}


+(void) setEntry:(GamificationDataEntry*)entry ForIdentifier:(NSUUID*)uuid{
    [data setObject:entry forKey:uuid];
}

+(GamificationDataEntry*) getEntryForIdentifier:(NSUUID*) uuid{
    return [data objectForKey:uuid];
}

@end
