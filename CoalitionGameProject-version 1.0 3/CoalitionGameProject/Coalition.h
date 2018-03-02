//
//  Coalition.h
//  CoalitionGameProject
//
//  Created by xiaoxiao on 11/02/2015.
//  Copyright (c) 2015 Xiaoyang Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Agent.h"
#import "Edge.h"

@interface Coalition : NSObject

@property (strong, nonatomic) NSMutableArray *agentsArray;   // members(agnets) of coalition
@property (strong, nonatomic) NSMutableArray *agentViewsArray;
@property (strong, nonatomic) NSMutableArray *edgesArray;    //
@property (strong, nonatomic) NSMutableArray *pathsArray;

@property (strong, nonatomic) NSNumber *coalitionValue;         // the uitility of the coalition
@property (nonatomic, strong) NSNumber *agentShapleyValue;

-(Coalition *)initWithAgents:(NSMutableArray *)agents
                    agentViews:(NSMutableArray *)agentViews
                       edges:(NSMutableArray *)edges
                       paths:(NSMutableArray *)paths;

//// Addition
//-(void) addAgentToCoalition:(Agent *)agent;
//-(void) addEdgeToCoalition:(Edge *)edge;
//
//// Deletion
//-(void) deleteAgent:(Agent *)agent;
//-(void) deleteEdge:(Edge *)edge;

// Get singletonCoalitions

-(NSMutableArray *)getSingletonCoalitions;
// Calculation
-(NSNumber *)calculateAgentShapleyValue:(Agent *)agent;
-(NSNumber *)calculateCoalitionValue;

-(NSMutableArray *)isCoalitionStable;

@end
