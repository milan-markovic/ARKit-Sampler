//
//  GamificationDataRepository.h
//  ARKit-Sampler
//
//  Created by Milan Markovic on 6/1/18.
//  Copyright © 2018 Shuichi Tsutsumi. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GamificationDataEntry : NSObject

@property(readwrite) int32_t gamified;

@end



@interface GamificationDataRepository : NSObject

+(void) setEntry:(GamificationDataEntry*)entry ForIdentifier:(NSUUID*)uuid;

+(GamificationDataEntry*) getEntryForIdentifier:(NSUUID*) uuid;


@end

