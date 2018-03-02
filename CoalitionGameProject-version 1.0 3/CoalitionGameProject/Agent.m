//
//  Agent.m
//  CoalitionGameProject
//
//  Created by xiaoxiao on 10/02/2015.
//  Copyright (c) 2015 Xiaoyang Wang. All rights reserved.
//

#import "Agent.h"

@implementation Agent

// ========================================
#pragma mark - Initialization
// ========================================
-(Agent *) initWithName:(NSString *)agentNameStr
            withPosition:(NSValue *)agentPosition
               andIndex:(NSInteger) index{
    self = [self init];
    
    if (self) {
        [self setAgentNameStr:agentNameStr];    // initialise the agent name
        [self setAgentPosition:agentPosition];  // initialise the agent position
        [self setIndex:index];                  // initialise the index with view tag
        [self setSelected:FALSE];
    }
    return self;
}

-(NSString *) getName{
    return self.agentNameStr;
}


// ========================================
#pragma mark - Update Position & Name
// ========================================
-(void) updatePosition:(NSValue *)newPosition{
    // update the agent position
    if (self.agentPosition) {
        [self setAgentPosition:newPosition];
    }
}

-(void) updateNameStr:(NSString *)newName{

}

//-(NSInteger) getNumberOfEdges{
//    return (int)[self numberOfEdgesInt];
//}

//-(NSNumber *) caculateAgentShapleyValue:(Agent *)agent{
//    
//    
//    // calculate here
//    
//    return self.agentShapleyValueFloat;
//}
@end
