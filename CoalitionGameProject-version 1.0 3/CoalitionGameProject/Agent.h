//
//  Agent.h
//  CoalitionGameProject
//
//  Created by xiaoxiao on 10/02/2015.
//  Copyright (c) 2015 Xiaoyang Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
// #import "Edge.h"

@class Edge;

@interface Agent : NSObject

@property (nonatomic,assign) NSInteger index;               // the index ofagent same with corresponding view tag
@property (nonatomic, strong) NSString *agentNameStr;       // the name of the agent
@property (nonatomic, strong) NSValue *agentPosition;       // the location of the agent

@property (nonatomic,strong) NSNumber *agentShapleyValue;   // the shaply value of agent
//@property (nonatomic, assign) NSInteger *numberOfEdgesInt;
//@property (nonatomic, strong) NSMutableDictionary *edgesLinkedToAgent;
//@property (nonatomic, strong) NSNumber *agentShapleyValueFloat;

//@property (nonatomic, strong) NSMutableArray *agentEdgesArray;
@property (nonatomic) BOOL selected;
// choose one of set name
-(Agent *) initWithName:(NSString *) agentNameStr
            withPosition:(NSValue *) agentPosition
               andIndex:(NSInteger) index;

// update the position of agent when user move it
-(void)updatePosition:(NSValue *) newPosition;



//-(void) setName:(NSString *) name;


//-(NSMutableArray *)getEdgesOfAgent;
//-(NSString *) getName;
//-(NSInteger) getNumberOfEdges;
//-(NSNumber *) caculateAgentShapleyValue:(Agent *)agent;


@end
