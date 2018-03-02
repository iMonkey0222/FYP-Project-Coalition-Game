//
//  GameAreaView.m
//  CoalitionGameProject
//
//  Created by xiaoxiao on 18/02/2015.
//  Copyright (c) 2015 Xiaoyang Wang. All rights reserved.
//

#import "GameAreaView.h"

#define STANDARDWIDTH 500       // standard width of view.bounds.size.width
#define STANDARDHEIGHT 500      // standard height of view.bounds.size.height
#define NUMBEROFDOTSALINE 10    // standard number of agent dots per width
#define PAN 12                  // standard pan distance from agent location

#define STARTX @"startPointx"
#define STARTY @"startPointy"

#define ENDX @"endPointx"
#define ENDY @"endPointy"

//#define RADIUS 25


@interface GameAreaView()
@property(nonatomic, assign) CGFloat ratio;         // the Ratio of current view bound with standard view bound
@property(nonatomic, assign) CGFloat CIRCLE_RADIUS; // dot daius
@property(nonatomic, assign) CGFloat ratioPan;      // PAN * ratio

//@property (nonatomic, strong) UILabel *weightLabel;   //dispaly the weight
@end

@implementation GameAreaView
@synthesize ratio, CIRCLE_RADIUS, ratioPan;

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();   // get the current graphic context
    CGContextSetLineWidth(context, 1.5f);                   // set width of the line
    CGContextSetStrokeColorWithColor(context, [UIColor darkGrayColor].CGColor);
    
    CGFloat currentBoundHeight = self.bounds.size.height;   // get the current view bound height
    CGFloat currentBoundWidth = self.bounds.size.width;     // get the current view bound width
    
    // * 1.1 Calculate the dot radius
    CGFloat const CIRCLE_DIAMETER  = currentBoundWidth / NUMBEROFDOTSALINE; // Diameter is read only
    CIRCLE_RADIUS = CIRCLE_DIAMETER / 2;
    
    // * 1.2 Calcualte the Ratio of current view bound with standard view bound
    ratio = currentBoundWidth / STANDARDWIDTH;
    
    // * 1.3 Calcualte ratio Pan
    ratioPan = PAN * ratio;
    
    // Draw
    for (NSDictionary *path in _pathArray) {
        
        // Convert startPointx and startPointy in path into CGPoint type
        CGPoint startPoint = CGPointMake([path[STARTX] floatValue], [path[STARTY] floatValue]);
        // Convert endPointx and endPointy in path into CGPoint type
        CGPoint endPoint = CGPointMake([path[ENDX] floatValue], [path[ENDY] floatValue]);
        
        // * 2. User selected start agent, then draw path
        
        // * 2.1 Find Selected Edge by Path
        Edge *edge = [self findEdgeByPath:path];
        
        // * 2.2 If path is self pointed ,then draw a curve
        if (CGPointEqualToPoint(startPoint, endPoint)) {
            //            NSLog(@"GAV: HI, curve, edge value %d", [edge.value intValue]);
            // Draw ARC Circle
            [self drawArcCircleWithPoint:startPoint withContext:context];
            
            // * Draw Text
            CGFloat x = (startPoint.x * ratio+ratioPan)+ CIRCLE_DIAMETER;
            CGFloat y = startPoint.y * ratio-10;
            [self drawTextAtxPosition:x yPosition:y withEdge:edge];
            
        }else{  //2.2 * Else if Path startPoint != endPoint
            
            // * Draw lines
            CGContextMoveToPoint(context, startPoint.x * ratio, startPoint.y * ratio);
            CGContextAddLineToPoint(context, endPoint.x * ratio, endPoint.y *ratio);
            
            // * Draw Text
            CGFloat x = (startPoint.x + endPoint.x)/2 * ratio;
            CGFloat y = (startPoint.y + endPoint.y)/2 * ratio;
            [self drawTextAtxPosition:x yPosition:y withEdge:edge];
            
        }
    }
    // Draw the path out
    CGContextStrokePath(context);
}

// =============================
#pragma mark - Draw Circle Arc
// =============================

-(void)drawArcCircleWithPoint:(CGPoint)agentLocation withContext:(CGContextRef)context{
    CGFloat ratioAgentLocationX = agentLocation.x * ratio;
    CGFloat ratioAgentLocationY = agentLocation.y * ratio;
    
    CGFloat startX = ratioAgentLocationX + ratioPan; // left point x
    CGFloat startY = ratioAgentLocationY;      // left point y
    CGContextMoveToPoint(context, startX, startY);
    
    CGPoint lu = CGPointMake(startX, startY-CIRCLE_RADIUS);            // left-up point
    CGPoint up = CGPointMake(startX+CIRCLE_RADIUS, startY-CIRCLE_RADIUS);     // up point
    CGPoint ru = CGPointMake(startX+2*CIRCLE_RADIUS, startY-CIRCLE_RADIUS);   // right-up point
    CGPoint right = CGPointMake(startX+2*CIRCLE_RADIUS, startY);       // right point
    CGPoint rd = CGPointMake(startX+2*CIRCLE_RADIUS, startY+CIRCLE_RADIUS);   // right-down point
    CGPoint down = CGPointMake(startX+CIRCLE_RADIUS, startY+CIRCLE_RADIUS);   // down point
    CGPoint ld = CGPointMake(startX, startY+CIRCLE_RADIUS);            // left-down point
    
    CGContextAddArcToPoint(context, lu.x, lu.y, up.x, up.y, CIRCLE_RADIUS);        // left-up arc
    CGContextAddArcToPoint(context, ru.x, ru.y, right.x, right.y, CIRCLE_RADIUS);  // right-up arc
    CGContextAddArcToPoint(context, rd.x, rd.y, down.x, down.y, CIRCLE_RADIUS);    // right-down arc
    CGContextAddArcToPoint(context, ld.x, ld.y, startX, startY, CIRCLE_RADIUS);    // left-down arc
}

// ==========================
#pragma mark - Draw Text
// ==========================
- (void)drawTextAtxPosition:(CGFloat)xPosition yPosition:(CGFloat)yPosition withEdge:(Edge *)edge
{
    //Draw Text
    NSMutableParagraphStyle* textStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
    textStyle.alignment = NSTextAlignmentLeft;
    
    double size = ratio*CIRCLE_RADIUS*4/5;  // resize the font size based on radius
    
    NSDictionary* textFontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: size], NSForegroundColorAttributeName: UIColor.darkGrayColor, NSParagraphStyleAttributeName: textStyle};
    
//    NSString *weight = [NSString stringWithFormat:@"%g", [edge.value floatValue]];

    NSString *weight = [NSString stringWithFormat:@"%d", edge.weightValue]; // {{4.27 modify}}
    
    [weight drawAtPoint:CGPointMake(xPosition, yPosition) withAttributes:textFontAttributes];
}

#pragma mark - Find edge by path
-(Edge *)findEdgeByPath:(NSDictionary *)path{
    Edge *edge;
    
    CGPoint startPoint = CGPointMake([path[STARTX] floatValue], [path[STARTY] floatValue]);
    CGPoint endPoint = CGPointMake([path[ENDX] floatValue], [path[ENDY] floatValue]);
    Agent *startAgent, *endAgent;
    
    for (Agent *a in _agentsArray) {
        CGPoint agentLocation = [[a agentPosition] CGPointValue];
        
        if (CGPointEqualToPoint(agentLocation, startPoint)) {
            NSLog(@"find startagent");
            startAgent = a;
        }
        
        if (CGPointEqualToPoint(agentLocation, endPoint)) {
            NSLog(@"find end agent");
            endAgent = a;
        }
    }
    
    for (Edge *e in _edgesArray) {
        if (e.startAgent == startAgent && e.endAgent == endAgent) {
            edge = e;
        }
    }
    return edge;
}

#pragma mark - Get the ratio
-(CGFloat)getRatio{
    return ratio;
}

#pragma mark - Get circle radius
-(CGFloat)getCircleRadius{
    return CIRCLE_RADIUS;
}

#pragma mark - Get ratio pan/transition
-(CGFloat)getRatioPan{
    return ratioPan;
}
//-(BOOL)addElementAtTouchPoint:(CGPoint)touchPoint{
//    bool updateOK = NO;
//}

//-(void)drawElementAtPoint:(CGPoint)touchPoint isAgent:(BOOL)elementType{
//    // initialise images
////    _agentNodeImage = [UIImage imageNamed:agentImageID];
////
////
////    UIImage *myImage = (elementType ? _agentNodeImage : _agentNodeImage);
////
////    [myImage drawAtPoint:touchPoint];
//}

//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
//
//}
//
//-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
//
//}
//
//-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
//
//}



@end
