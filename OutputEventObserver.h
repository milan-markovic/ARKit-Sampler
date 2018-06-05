//
//  OutputEventObserver.h
//  ARKit-Sampler
//
//  Created by Milan Markovic on 5/31/18.
//  Copyright © 2018 Shuichi Tsutsumi. All rights reserved.
//

#ifndef OutputEventObserver_h
#define OutputEventObserver_h

@protocol OutputEventObserver

-(void) onOutputEvent:(NSUUID*) eventId;

@end


#endif /* OutputEventObserver_h */
