//
//  GameCell.h
//  CoalitionGameProject
//
//  Created by xiaoxiao on 19/02/2015.
//  Copyright (c) 2015 Xiaoyang Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameAreaView.h"
@interface GameCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *gameCellTitle;      // the title of the game
@property (strong, nonatomic) IBOutlet GameAreaView *gameAreaView;  // instance of GameAreaView
@end
