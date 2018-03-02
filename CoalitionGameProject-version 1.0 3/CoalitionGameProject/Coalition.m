//
//  Coalition.m
//  CoalitionGameProject
//
//  Created by xiaoxiao on 11/02/2015.
//  Copyright (c) 2015 Xiaoyang Wang. All rights reserved.
//

#import "Coalition.h"
#import "Agent.h"
#import "Edge.h"

@implementation Coalition

-(Coalition *)initWithAgents:(NSMutableArray *)agents
                  agentViews:(NSMutableArray *)agentViews
                       edges:(NSMutableArray *)edges
                       paths:(NSMutableArray *)paths
{
    self = [self init];
    
    [self setAgentsArray:agents];
    [self setAgentViewsArray:agentViews];
    [self setEdgesArray:edges];
    [self setPathsArray:paths];
//    // Iterate through the agents array to construct the array
//    Agent *agent;
//    
//    for (NSDictionary *kqElement in agents) {
//        agent = [[Agent alloc] initWithName:[kqElement objectForKey:@"name"]
//                 withPosition:(NSValue *)([kqElement objectForKey:@"position"])];
//        
//        [[self agentsArray] addObject:agent];
//    }
//    
//    // Iterate through the edges array to construct the array
//    Edge *edge;
//    
//    for (NSDictionary *kqElement in edges) {
//        edge = [[Edge alloc] initWithStartAgent:[kqElement objectForKey:@"start"]
//                                       endAgent:[kqElement objectForKey:@"end"]
//                                       andValue:[kqElement objectForKey:@"value"]];
//        [[self edgesArray] addObject:edge];
//    }
    return self;
}



-(NSNumber *)calculateAgentShapleyValue:(Agent *)agent{

    double sum = 0;
    
    for (Edge *e in _edgesArray) {
        Agent *startAgent = e.startAgent;
        Agent *endAgent = e.endAgent;
        
//        // For singlton coalition, SV is it earned
//        if (agent == startAgent && agent == endAgent) {
//            sum = sum + (double)e.weightValue;
//        }  // If the edge is connected with this agent, then add edge value to sum
        if (agent == startAgent || agent == endAgent){
            // Add edges that not connect to agent itself together and /2
            if (!(agent == startAgent && agent == endAgent)) {
                sum = sum + (double)e.weightValue/2;
            }
        }
    }
    // Convert it to NSnumber
    _agentShapleyValue = [NSNumber numberWithDouble:sum];
    return _agentShapleyValue;
}

-(NSNumber *)calculateCoalitionValue{
    double sum = 0;
    
    for (Edge *e in _edgesArray) {
        sum = sum + (double)e.weightValue;
    }
    
    _coalitionValue = [NSNumber numberWithDouble:sum];
    return _coalitionValue;
}

-(NSMutableArray *)getSingletonCoalitions{
    NSMutableArray *singletonCoalitions = [[NSMutableArray alloc] init];
    for (Edge *e in _edgesArray) {
        if (e.startAgent == e.endAgent) {
            [singletonCoalitions addObject:e.startAgent];
        }
    }
    return singletonCoalitions;
}

#pragma mark Verify the stability of coalition
-(NSMutableArray *)isCoalitionStable{
//    BOOL isStable = FALSE;
    NSMutableArray *objectsAgentsName = [[NSMutableArray alloc] init];
    NSMutableArray *singletonAgents = [[NSMutableArray alloc] initWithArray:[self getSingletonCoalitions]];

    for (Agent *a in singletonAgents) {
        
        double agentSV = [[self calculateAgentShapleyValue:a] floatValue];
        double edgeWeight = 0.0;
        
        for (Edge *e in _edgesArray) {
            if (e.startAgent == a && e.endAgent == a) {
                edgeWeight = (double)e.weightValue;
                break;
            }
        }
        
        if (edgeWeight > agentSV) {
//            isStable = TRUE;
            [objectsAgentsName addObject:a.agentNameStr];
        }
    }
    
    return objectsAgentsName;
//    return isStable;
}

//-(void)addAgentToCoalition:(Agent *)agent{
//    [[self agentsArray] addObject:agent];
//}
//
//-(void)addEdgeToCoalition:(Edge *)edge{
//    [[self edgesArray] addObject:edge];
//}

//-(void)deleteAgent:(Agent *)agent{
//    // delete selected agent
//    [[self agentsArray] removeObject:agent];
//    // delete edges linked to it
//    for(int i = 0; i < [self.edgesArray count]; i++){
////        if () {
////            <#statements#>
////        }
//    }
//
//}
//
//-(void)deleteEdge:(Edge *)edge{
//    [[self edgesArray] removeObject:edge];
//}

@end






