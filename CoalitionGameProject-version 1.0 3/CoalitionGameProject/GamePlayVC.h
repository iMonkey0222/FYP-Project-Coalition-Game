//
//  GamePlayVC.h
//  CoalitionGameProject
//
//  Created by xiaoxiao on 17/02/2015.
//  Copyright (c) 2015 Xiaoyang Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameAreaView.h"
#import "PropertySetView.h"
#import "Agent.h"
#import "Edge.h"
#import "Coalition.h"

@interface GamePlayVC : UIViewController
@property (strong, nonatomic) IBOutlet GameAreaView *gameAreaView;

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *gameListTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *longPressLabel;


@property (strong, nonatomic) NSMutableArray *agentsArray;
@property (strong, nonatomic) NSMutableArray *edgesArray;
@property (strong, nonatomic) NSMutableArray *pathArray;

//@property (strong, nonatomic) IBOutlet DrawToolView *drawToolView;

-(IBAction)unwindToMainStoryBoard:(UIStoryboardSegue *)unwindSegue;
@end
