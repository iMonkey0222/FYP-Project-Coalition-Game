//
//  Edge.h
//  CoalitionGameProject
//
//  Created by xiaoxiao on 10/02/2015.
//  Copyright (c) 2015 Xiaoyang Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Agent.h"
@interface Edge : NSObject
@property (strong, nonatomic) Agent *startAgent;
@property (strong, nonatomic) Agent *endAgent;
@property (assign, nonatomic) int weightValue;

-(Edge *) initWithStartAgent:(Agent *)startAgent
                    endAgent:(Agent *)endAgent
                    andValue:(int)weightValue;

@end
