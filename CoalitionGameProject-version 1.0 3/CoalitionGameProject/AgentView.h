//
//  DragView1.h
//  CoalitionGameProject
//
//  Created by xiaoxiao on 10/03/2015.
//  Copyright (c) 2015 Xiaoyang Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Agent.h"

@interface AgentView : UIView
{
    
    CGPoint lastLocation;
}
@property (strong, nonatomic)Agent *agentM;
@property (nonatomic,assign) CGFloat radius;

@end
