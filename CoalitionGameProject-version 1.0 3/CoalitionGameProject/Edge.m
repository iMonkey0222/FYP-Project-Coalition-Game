//
//  Edge.m
//  CoalitionGameProject
//
//  Created by xiaoxiao on 10/02/2015.
//  Copyright (c) 2015 Xiaoyang Wang. All rights reserved.
//

#import "Edge.h"

@implementation Edge

-(Edge *) initWithStartAgent:(Agent *)startNode
                    endAgent:(Agent *)endNode
                    andValue:(int)weightValue{
    self = [self init];
    
    [self setStartAgent:startNode];
    [self setEndAgent:endNode];
    [self setWeightValue:weightValue];
    
    return self;
}
@end
