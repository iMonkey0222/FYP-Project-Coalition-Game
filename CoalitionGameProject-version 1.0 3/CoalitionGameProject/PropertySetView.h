//
//  DrawToolView.h
//  CoalitionGameProject
//
//  Created by xiaoxiao on 01/03/2015.
//  Copyright (c) 2015 Xiaoyang Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Agent.h"
#import "Edge.h"
//@protocol confirmButtonDeletgate
//-(void)didButtonPressed;
//@end


@interface PropertySetView : UIView
//@property (nonatomic, assign) id <confirmButtonDeletgate> delegate;
@property (nonatomic, strong) Agent *agent;
@property (nonatomic, strong) Edge *edge;

@property (nonatomic, strong) IBOutlet UITextField *agentNameInput;     // name input
@property (nonatomic, strong) IBOutlet UITextField *edgeWeightInput;    // weight input
@property (nonatomic, strong) IBOutlet UIButton *confirm;               // submit update
-(IBAction)submit:(id)sender;
@end
