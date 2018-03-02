//
//  DrawToolView.m
//  CoalitionGameProject
//
//  Created by xiaoxiao on 01/03/2015.
//  Copyright (c) 2015 Xiaoyang Wang. All rights reserved.
//

#import "PropertySetView.h"

@interface PropertySetView()
@property (nonatomic, strong) NSString *placeholder;
@end

@implementation PropertySetView

@synthesize agentNameInput,edgeWeightInput;

#pragma mark Verify the weight input is numeric
-(BOOL)inputIsNumeric:(NSString *)input
{
    BOOL result = FALSE;

    return result;
}

-(void)awakeFromNib{
    [super awakeFromNib];
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    if (_agent != nil) {
        if (_agent.agentNameStr) {
            agentNameInput.text = _agent.agentNameStr;
        }
    }else
        agentNameInput.text = nil;
    
    if (_edge != nil) {
        if(_edge.weightValue){
            edgeWeightInput.text = [NSString stringWithFormat:@"%d", _edge.weightValue];
        }
    }else
        edgeWeightInput.text = nil;
}


-(IBAction)submit:(id)sender{
    if(_agent != nil){
        if(agentNameInput.text != nil){
            NSString *name = agentNameInput.text;
            // If user type new name, then update
            if (![_agent.agentNameStr isEqualToString:name]) {
                _agent.agentNameStr = name;
            }
        }
    }

    
    if (_edge != nil) {
        if (edgeWeightInput.text != nil) {
//            double weight = [edgeWeightInput.text doubleValue];
            int weight = [edgeWeightInput.text intValue]; // {{4.27}}
            
            // If user type new weight, then update
            
//            if (!([_edge.value floatValue] == weight)) {
            //{{4.27}}
            if (!(_edge.weightValue == weight)) {
                _edge.weightValue = weight;
            }
        }
    }

}



@end
