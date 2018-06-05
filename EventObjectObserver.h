//
//  EventObjectObserver.h
//  ARKit-Sampler
//
//  Created by Milan Markovic on 5/31/18.
//  Copyright © 2018 Shuichi Tsutsumi. All rights reserved.
//

#ifndef EventObjectObserver_h
#define EventObjectObserver_h

@protocol EventObjectObserver

-(void) onEventObjectClick:(NSUUID*) eventId;

@end


#endif /* EventObjectObserver_h */
