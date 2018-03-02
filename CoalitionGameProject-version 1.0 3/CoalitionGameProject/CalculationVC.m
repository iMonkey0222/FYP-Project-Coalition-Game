//
//  CalculationVC.m
//  CoalitionGameProject
//
//  Created by xiaoxiao on 26/04/2015.
//  Copyright (c) 2015 Xiaoyang Wang. All rights reserved.
//

#import "CalculationVC.h"

@interface CalculationVC ()
@property (strong, nonatomic) IBOutlet UILabel *stableStatus;
@property (strong, nonatomic) IBOutlet UILabel *singletonCoalitionValue;
@property (strong, nonatomic) IBOutlet UILabel *coalitionLabel;
@property (strong, nonatomic) IBOutlet UILabel *coalitionTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *agentsTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *agentsSVLabel;

@end

@implementation CalculationVC
-(void)setText:(NSString *)msg ofLabel:(UILabel *)label{
    
    label.numberOfLines = 0;// Set numberOfLines to 0 to allow for any number of lines
    
    // * Calcualte the label size based on message font size.
    CGSize labelSize = [msg sizeWithAttributes:@{NSFontAttributeName:label.font}];
    // * Set label height as the calculated labelSize.height
    label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y,
                             label.frame.size.width, labelSize.height);
    // * Set label text
    [label setText:msg];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _coalitionLabel.numberOfLines = 0; // Set numberOfLines to 0 to allow for any number of lines

    if (_coalition != nil) {
        if (_coalition.agentsArray.count == 0) {    // If user did not create characteristic function
            [_coalitionLabel setText:@"There is no result to display. \n Please create a coalition first."];
        }else{
            // {{4.30 Coalition stablility}}
            NSMutableArray *objectsAgents = [[NSMutableArray alloc] init];
            objectsAgents = [_coalition isCoalitionStable];
            NSLog(@"ObjectsAgents %@", objectsAgents);
            if (objectsAgents.count > 0) {
                NSString *agentsName = [objectsAgents componentsJoinedByString:@","];
                [_stableStatus setText:[NSString stringWithFormat:@"Coalition is unstable, %@ will object.",agentsName]];
            }else
                [_stableStatus setText:@"Coalition is stable"];

            
            
            // * 1. Calculate the SV
            NSNumber *coalitionSV = _coalition.calculateCoalitionValue;
            NSNumber *agentSV = 0;
            NSString *agentMsg = @"";
            
            for (Agent *a in _coalition.agentsArray) {
                agentSV = [_coalition calculateAgentShapleyValue:a];
                agentMsg = [agentMsg stringByAppendingFormat:@"sh( %@ ) = %g \n", a.agentNameStr, [agentSV floatValue]];
            }
            
            [self setText:agentMsg ofLabel:_agentsSVLabel]; // set the text of label

            
            
            //* 2.  {{4.29}} Coalition Value
            NSMutableArray *coalitionElementsName = [[NSMutableArray alloc] init];
            for (Agent *a in _coalition.agentsArray) {
                //        coalitionEle = [coalitionEle stringByAppendingFormat:@"%@,"];
                [coalitionElementsName addObject:a.agentNameStr];
            }
            NSString *coalitionEle = [coalitionElementsName componentsJoinedByString:@","];
            
            //* 3. {{4.29 }} singleton Coalition
            NSString *singletonMsg = @"";
            for (Agent *single in _coalition.getSingletonCoalitions) {
                for (Edge *e in _coalition.edgesArray) {
                    if (e.startAgent == single && e.endAgent == single) {
                        singletonMsg = [NSString stringWithFormat:@"%@ v({ %@ })= %d ",singletonMsg, single.agentNameStr, e.weightValue];
                    }
                }
            }
            [self setText:singletonMsg ofLabel:_singletonCoalitionValue];
            
            // * set the title
            [_coalitionTitleLabel setText:[NSString stringWithFormat:@"Coalition Value"]];
            [_agentsTitleLabel setText:@"Agents Shapely Value"];
            
            // * use %g to display value
            NSString *msg = [NSString stringWithFormat:@"v({ %@ }) = %g",coalitionEle, [coalitionSV floatValue]];
            [_coalitionLabel setText:msg];
        
        }
    }else{
        [_coalitionLabel setText:@"There is no result to display. \n Please create a coalition first."];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
