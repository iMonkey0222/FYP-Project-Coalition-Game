//
//  GameAreaView.h
//  CoalitionGameProject
//
//  Created by xiaoxiao on 18/02/2015.
//  Copyright (c) 2015 Xiaoyang Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameAreaView.h"
#import "Agent.h"
#import "Edge.h"
#import "Coalition.h"


@interface GameAreaView : UIView
@property (strong, nonatomic) NSMutableArray *agentsArray;
@property (strong, nonatomic) NSMutableArray *agentViewsArray;

@property (strong, nonatomic) NSMutableArray *edgesArray;
@property (strong, nonatomic) NSMutableArray *pathArray;

-(CGFloat)getRatio;             // get the ratio
-(CGFloat)getCircleRadius;      // get the radius of circle
-(CGFloat)getRatioPan;          // get the pan distance from agent location

@end
