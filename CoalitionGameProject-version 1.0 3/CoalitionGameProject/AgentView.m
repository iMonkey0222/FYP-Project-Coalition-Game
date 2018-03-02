//
//  DragView1.m
//  CoalitionGameProject
//
//  Created by xiaoxiao on 10/03/2015.
//  Copyright (c) 2015 Xiaoyang Wang. All rights reserved.
//

#import "agentView.h"


@interface AgentView()
@property (strong, nonatomic) UILabel *nameLabel;

@end


@implementation AgentView
@synthesize radius,nameLabel;

-(id) initWithFrame:(CGRect)frame
{;
    [self setOpaque:NO]; // set it NO if the view is fully or partially transparent.
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.userInteractionEnabled = YES;
        
        // {{Originally pan way}}
        //        UIPanGestureRecognizer *panRecoginizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        //        self.gestureRecognizers = @[panRecoginizer];
        
        //        _name = _agentM.agentNameStr; // get the agent name
        radius = frame.size.width / 2;
    }
    //        _frame = frame;
    return self;
}


- (void)awakeFromNib
{
    [super awakeFromNib];
}


// Draw circle

- (void)drawRect:(CGRect)rect {
    
    // Draw a circle
    
    CGContextRef contextRef = UIGraphicsGetCurrentContext();    // Initialize contextRef
    CGContextSetLineWidth(contextRef, 2.0);                     // set the line width
    
    CGContextSetRGBFillColor(contextRef, 0, 0, 255, 0.1);       // set the fill color
    CGContextSetRGBStrokeColor(contextRef, 0, 0, 255, 0.5);     // set the stroke color
    
    // 1. Draw a circle (filled) with
    CGContextFillEllipseInRect(contextRef, CGRectMake(100, 100, radius, radius));
    
    // 2. Draw a circle (border only)
    CGContextStrokeEllipseInRect(contextRef, CGRectMake(0, 0, radius*2, radius*2));
    
    // 3. Draw text
    [self drawTextInNameLabel];
}

- (void)drawTextInNameLabel
{
    //{{4.23 Modify to textlabel --- adjustsFontSizeFitWidth}}
    [nameLabel removeFromSuperview];        // Remove previous nameLabel
    
    double size = radius*3/5;               // Resize the font based on the radius
    UIFont * customFont = [UIFont fontWithName:@"Helvetica" size:size]; //custom font
    NSString * text = _agentM.agentNameStr;
    
    nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, radius*2, radius*2)];
    nameLabel.text = text;
    nameLabel.font = customFont;
    nameLabel.numberOfLines = 1;
    nameLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines; // or UIBaselineAdjustmentAlignCenters, or UIBaselineAdjustmentNone
    nameLabel.adjustsFontSizeToFitWidth = YES;
    nameLabel.minimumScaleFactor = 8.0f/12.0f;
    nameLabel.clipsToBounds = YES;
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.textColor = [UIColor blackColor];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    
    [self addSubview:nameLabel];
}
/**
 4.23 This is previous way to dispaly text
 **/
//Draw Text
//    CGRect textRect = CGRectMake(xPosition, yPosition, canvasWidth, canvasHeight);
//    NSMutableParagraphStyle* textStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
//    textStyle.alignment = NSTextAlignmentLeft;
//
//    CGFloat size = radius* (3/5);
//    NSDictionary* textFontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: size], NSForegroundColorAttributeName: UIColor.darkGrayColor, NSParagraphStyleAttributeName: textStyle};
//
//    [_agentM.agentNameStr drawInRect: textRect withAttributes: textFontAttributes];


/**
 4.11 modify tap
 **/
//-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
//    self.isPressed = YES;
//    self.isLongPressed = NO;
//
//    // Promote the touched view
//    [self.superview bringSubviewToFront:self];
//
//    // Remember original location
//    lastLocation = self.center;
//    [self setNeedsDisplay];
//
//    NSLog(@"- Agent %@ is selected.",_name);
//
//}
//
//-(void) handlePan:(UIPanGestureRecognizer *) gesRecognizer{
//    CGPoint translation = [gesRecognizer translationInView:self.superview];
//    //* Update view center location
//    self.center = CGPointMake(lastLocation.x + translation.x,
//                              lastLocation.y + translation.y);
////    NSLog(@"view new position: %.0f, %.0f", self.center.x, self.center.y);
//
//    //* Upadte the agentM(odel) location
//    _agentM.agentPosition = [NSValue valueWithCGPoint:self.center];
////    NSLog(@"agent new position: %@", _agentM.agentPosition);
//}
//
//-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    self.isPressed = NO;
//    self.name = @"pp"; // test
//    [self setNeedsDisplay];
//    NSLog(@"Test: Agent %@ is changed name.",_name);
//}



@end
