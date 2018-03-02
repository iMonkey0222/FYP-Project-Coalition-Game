//
//  GamePlayVC.m
//  CoalitionGameProject
//
//  Created by xiaoxiao on 17/02/2015.
//  Copyright (c) 2015 Xiaoyang Wang. All rights reserved.
//

#import "GamePlayVC.h"
#import "GameCell.h"
#import "AgentView.h"
#import "CalculationVC.h"

static NSString* const history = @"history-1";

#define DISTANCE 20             // the max distance between point to circle
#define ANIMATION_DURATION 0.9  // the duration of the long press animation
#define ANIMATION_REPEAT HUGE_VALF //repeat forever // delete me

#define STARTX @"startPointx"
#define STARTY @"startPointy"
#define ENDX @"endPointx"
#define ENDY @"endPointy"


@interface GamePlayVC ()

@property (strong, nonatomic) NSMutableArray *gameList;         // gameList array
@property (strong, nonatomic) Coalition *coalition;             // coalition Object
@property (strong, nonatomic) NSMutableArray *dotViewsArray;    // store agent views

@property (nonatomic) BOOL isGameGuideViewed;
@property (nonatomic) BOOL isCreateGamePressed;
@property (nonatomic) BOOL isDotSelected;
@property (nonatomic) BOOL isDeletePressed;

@property (nonatomic) CGFloat CIRCLE_RADIUS;
@property (nonatomic) CGFloat PAN;
@property (nonatomic) NSInteger tag;                // the tag value of agent dot view
@property (nonatomic) CGPoint pathStartPoint;       // the start point of the path
@property (nonatomic) NSInteger pathStartViewTag;   // the start view tag of path (also the index of agent in agentsArray)

@property (strong, nonatomic) IBOutlet UITableView *gameTable;
@property (strong, nonatomic) IBOutlet PropertySetView *drawToolsView;

@property (nonatomic,strong) UILongPressGestureRecognizer *lpgr; // Long Pressgesture
@property (nonatomic,strong)IBOutlet UIButton *createGame;
@property (nonatomic, strong)IBOutlet UIButton *caculate;
@property (nonatomic,strong)IBOutlet UIButton *dot;
@property (nonatomic,strong)IBOutlet UIButton *delete;

- (IBAction)createNameGame:(id)sender;
- (IBAction)deleteButtonPressed:(id)sender;
- (IBAction)dotButtonPressed:(id)sender;
- (IBAction)caculateShapleyValue:(id)sender;


@end

@implementation GamePlayVC

@synthesize CIRCLE_RADIUS, PAN;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // * Lead user to view game guide first
    UIAlertView *gameGuideAlert = [[UIAlertView alloc] initWithTitle:@"Read Game Guide First." message:nil delegate:self cancelButtonTitle:@"OK, Go to read Game Guide." otherButtonTitles:nil, nil];
    [gameGuideAlert show];
    
    // Initialise the game List
    _gameList = [[NSMutableArray alloc] init];
    
    // * Initialize the agents array and pathArray
    _agentsArray = [[NSMutableArray alloc] init];
    _edgesArray = [[NSMutableArray alloc] init];
    _pathArray = [[NSMutableArray alloc] init];
    
    
//    _isDotSelected = FALSE;     // dot is not selected at first
//    _isCustomCoalitionPressed = FALSE;
//    _isDeletePressed = FALSE;
//    _tag = -1;                  // initialize the tag value of uiview as -1
    
    // [self.title setText:@"Welcome to Play the Game"];
    _gameAreaView.layer.cornerRadius = 20.0; // set layer corner radius as 20
    [[self gameAreaView] setClipsToBounds:true]; // UiView Clip to display the view in gameAreaView bound

    // {{modify under 3 lines to one line}}
    [self updateGameAreaViewValue];
//    [_gameAreaView setAgentsArray:_agentsArray];    // pass agentsArray to gameAreaView
//    [_gameAreaView setEdgesArray:_edgesArray];      // pass edgesArray to gameAreaView
//    [_gameAreaView setPathArray:_pathArray];
    
    _drawToolsView.layer.cornerRadius = 20.0; // set layer corner radius as 20
//{{modify 4.22}}
    // set confirm button delete as my viewController
    [_drawToolsView.confirm addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
}

// ====================================
#pragma mark Confirm Button Selector
// ====================================
-(void)buttonTapped:(id)sender{
    // * 1. Update long pressed title
    for (Agent *a in _agentsArray) {
        if (CGPointEqualToPoint(_pathStartPoint, [a.agentPosition CGPointValue])) {
            [_longPressLabel setText:[NSString stringWithFormat:@"Move Directions Tips:\n   (In Blue Area) \nDraw curve: move to agent %@ \nDraw line: move to target agent you want to connect.\n", a.agentNameStr]];
        }
    }
    
    // * 2. Update selection title Label content
    [self.titleLabel setText:nil];  // display to title label
    
    // * 3. Update coalition value and GAV value
    [self updateCurrentCoalitionValue];
    [self updateGameAreaViewValue];
    NSLog(@"ATENTION!!!!!");
    [self printEdgesArray];
    
    // * 4. Update views
    [_gameAreaView setNeedsDisplay];        // update edges value in gameAreaView
    
    for (AgentView *v in _dotViewsArray) {   // update all dotViews
        [v setNeedsDisplay];
    }
    // {{4.30 update table cell} }
    [_gameTable reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark Create a new Game
- (IBAction)createNameGame:(id)sender {
    NSLog(@"Create a new Game");
    _isCreateGamePressed = TRUE;    // Update bool value
    
    NSMutableArray *agentsArray = [[NSMutableArray alloc] init];
    NSMutableArray *agentViewsArray = [[NSMutableArray alloc] init];
    NSMutableArray *edgesArray = [[NSMutableArray alloc] init];
    NSMutableArray *pathArray = [[NSMutableArray alloc] init];

    // * 1. Update tool Button and tag value
    _isDotSelected = FALSE;     // dot is not selected at first
    _isDeletePressed = FALSE;
    _tag = -1;                  // initialize the tag value of uiview as -1
    [self updateFunctionRemind];
    [_longPressLabel setText:nil];
    
    // * 2.1 Init a new coalition
    _coalition = [[Coalition alloc] initWithAgents:agentsArray agentViews:agentViewsArray edges:edgesArray paths:pathArray];
    [_gameList addObject:_coalition];
    
    // * 2.2 Set agentsArray, edgesarray, pathArray as _coliation's value
    _agentsArray = _coalition.agentsArray;
    _dotViewsArray = _coalition.agentViewsArray;
    _edgesArray = _coalition.edgesArray;
    _pathArray = _coalition.pathsArray;
    
    // * 3.1 Update property set view
    [_drawToolsView setAgent:nil];
    [_drawToolsView setEdge:nil];
    [_drawToolsView setNeedsDisplay];
    
    // * 3.2 Update gameAreaView
    [self updateGameAreaViewValue];
    [_gameAreaView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_gameAreaView setNeedsDisplay];
    
    [_gameTable reloadData];    // reload data in game Table

    NSLog(@"GameList %@", _gameList);
        [self printGameList];
}

-(IBAction)unwindToMainStoryBoard:(UIStoryboardSegue *)unwindSegue{
    NSLog(@"Unwind to from game guide!");
}

-(IBAction)unwindToGamePaly:(UIStoryboardSegue *)unwindSegue{
    NSLog(@"Unwind from shapley value");
}
// ========================================
#pragma mark - Tool Buttons
// ========================================
- (IBAction)dotButtonPressed:(id)sender{
    // In case user did not create a game first
    if (_isCreateGamePressed == TRUE) {
        if (_isDotSelected == TRUE) {
            _isDotSelected = FALSE;
        }else{
            _isDotSelected = TRUE;
            _isDeletePressed = FALSE;
            
        }
        [self updateFunctionRemind];            // Update button status
        _pathStartPoint = CGPointMake(0, 0);    // Update pathstratPoint to (0,0)
    }else
        [self alertCreateGame];
}

- (IBAction)deleteButtonPressed:(id)sender{
    // In case user did not create a game first
    if (_isCreateGamePressed == TRUE) {
        if (_isDeletePressed == TRUE) {
            _isDeletePressed = FALSE;
        }else{
            _isDeletePressed = TRUE;
            _isDotSelected = FALSE;
        }
        
        [self updateFunctionRemind];                // Update button status
    }else
        [self alertCreateGame];
}

- (IBAction)caculateShapleyValue:(id)sender {
    //* 1. update delete pressed to False
    _isDeletePressed = FALSE;
    [self updateFunctionRemind];
    
    // * {{4.26}}
    if (_isCreateGamePressed) {
        if (_agentsArray.count == 0) {  // If user did not create characteristic function
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reminding: " message:@"Please create a coalition first. \n\n Press dot button \n to start generating \n Characteristic Function." delegate:self cancelButtonTitle:@"OK, press dot now." otherButtonTitles:nil, nil];
            [alert show];
        }
    }else
        [self alertCreateGame];

    
    // * 2. Calculate the SV
    NSNumber *agentSV = 0;
    for (Agent *a in _coalition.agentsArray) {
        agentSV = [_coalition calculateAgentShapleyValue:a];
        NSLog(@"Agent %@ shapley value is %f", a.agentNameStr, [agentSV floatValue]);
    }
}

#pragma mark Alert User To Create a Game First
-(void)alertCreateGame{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reminding: " message:@"Please create a game first. \n" delegate:self cancelButtonTitle:@"OK, Go to create a game." otherButtonTitles:nil, nil];
    [alert show];
}

#pragma Update dot & delete Button
-(void)updateFunctionRemind{
    
    if (_isDotSelected) {
        [_dot setSelected:YES];
    }else
        [_dot setSelected:NO];
    
    if (_isDeletePressed) {
        [_delete setSelected:YES];
    }else
        [_delete setSelected:NO];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"showShapleyValueSegue"]) {
        CalculationVC *controller = (CalculationVC *)segue.destinationViewController;
        [controller setCoalition:_coalition];
    }
}



// ========================================
#pragma mark - Touch Events
// ========================================
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    // if the view of touch id equals to the view of gameAreaView
    if ([touch view]==[self gameAreaView]) {
        // {{4.27}} Add Limitation
    }
    [_gameAreaView setNeedsDisplay];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    if (_isDotSelected) {
        
        CGPoint startPoint = _pathStartPoint;// get the start point
        
        // If user did not select the start point, then alert warning
        if (CGPointEqualToPoint(startPoint,CGPointMake(0, 0))) {
        
            if (_agentsArray.count == 0) {
                // If user has not create an agent
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reminding: " message:@"Please generate the \n Characteristic Function. \n\n You can create an agent first. \n\n Double Tap to create an agent." delegate:self cancelButtonTitle:@"OK, double tap now. " otherButtonTitles:nil, nil];
                [alert show];
            }else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reminding: " message:@"Please long press the agent dot,\n release after animation. \n\n Have Fun! " delegate:self cancelButtonTitle:@"OK, long press an agent now." otherButtonTitles:nil, nil];
                [alert show];
            }
        }
        
        UITouch *touch = [touches anyObject];
        if ([touch view] == [self gameAreaView]) {
            NSLog(@"TOUCHMOVED:  In game area");
            
            CGPoint currentLocation = [touch locationInView:[self gameAreaView]];
            
            
            BOOL isNearTarget = FALSE;  // check touchpoint is near a agent node
            CGPoint endPoint;           // store the end point of the line need to be drawn
            
            /**
             Find through the agentsArray, compare the current location to target agent location,
             - If distance between current point and the nearest targetAgent.center is radius+Distance, then set endPoint to targetLocation;
             - Else draw nothing
             **/
            
            for (int i = 0; i<_agentsArray.count; i++) {
                // Get each anget center location and Convert to CGPoint value
                CGPoint targetAgentLocation = [[_agentsArray[i] agentPosition] CGPointValue];
        
                double x = currentLocation.x-targetAgentLocation.x;
                double y = currentLocation.y-targetAgentLocation.y;
                double squareDistance = pow(x, 2) + pow(y, 2);
                double minCircle = pow(CIRCLE_RADIUS, 2);
                double maxCircle = pow(CIRCLE_RADIUS+DISTANCE, 2);

                if (squareDistance<= maxCircle && squareDistance >=minCircle) {
                    isNearTarget = TRUE;            // set isNearTarget to true
                    endPoint = targetAgentLocation; // set endPoint to target agent location
                }
                // * else display nothing.
            }
            
            // * If current location is near target agent, then call add function and set pathArray of gameAreaView to updated pathArray
            if (isNearTarget) {
                // add start and end point to pathArray
                [self addStartPoint:startPoint andEndPoint:endPoint];
                
                // pass pathArray to gameAreaView
                [_gameAreaView setPathArray:_pathArray];
                
                isNearTarget = FALSE;
                
                // {{4.24 }}
                [self updateCurrentCoalitionValue];
                [self updateGameAreaViewValue];
                [_gameAreaView setNeedsDisplay]; // update
                [_gameTable reloadData];
            }
            
        }else{
            NSLog(@"TOUCHMOVED: Out of game area");
        }
    }
//    [_gameAreaView setNeedsDisplay]; // update
}


//touchesEnded method is invoked when the touch events end (i.e. when the fingers are lifted from the screen),
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    
    if ([touch view]==[self gameAreaView]) {
        CGPoint touchPoint = [touch locationInView:[self gameAreaView]];

        // ** Add dot view when tap twice
        if (_isDotSelected) {
            // * If there is no long press detected, then draw a agent View
            if (touch.tapCount>=2) {
                [self loadView:touchPoint]; //load agent draggable view
                
//            }else if (_agentsArray.count == 0){
//                // * If user want to create an agent by single tap
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reminding: " message:@"You should \n Double Tap \n to create an agent." delegate:self cancelButtonTitle:@"OK, double tap now. " otherButtonTitles:nil, nil];
//                [alert show];
                
            }else{
                // ** If there exist path, then
                // Allow user to set edge weight
                if (_pathArray.count > 0) {
                    NSLog(@"Set the edge Weight!!");
                    BOOL isOnSegment = FALSE;
                    NSDictionary *selectedPath;
                    
                    for (NSDictionary *path in _pathArray) {
                        CGPoint startPoint = CGPointMake([path[STARTX] floatValue], [path[STARTY] floatValue]);
                        CGPoint endPoint = CGPointMake([path[ENDX] floatValue], [path[ENDY] floatValue]);
                        
                        if (CGPointEqualToPoint(startPoint, endPoint)) {
                            // Check point to circle arc
                            isOnSegment = [self isArcCircleWithAgentLocation:startPoint WithinDistance:5 fromPoint:touchPoint];
                            NSLog(@"Set arc value: Find the arc! Is it on the arc? %d", isOnSegment);
                        }
                        else{
                            // Check point to line segment
                            isOnSegment = [self isLineSegmentWithPoint:startPoint andPoint:endPoint withinDistance:5 fromPoint:touchPoint];
                            NSLog(@"SEt path value: Find the path! Is it on the line? %d", isOnSegment);
                        }
                        
                        
                        if (isOnSegment == TRUE) {
                            NSLog(@"Set weight: Find path!");
                            selectedPath = path;
                            break; // break the loop
                        }
                    }
                    
                    // find the edge by path
                    Edge *selectedEdge = [self findEdgeByPath:selectedPath];
                    
                    // * Update title label
                    NSString *msg;
                    Agent *start = selectedEdge.startAgent;
                    Agent *end = selectedEdge.endAgent;
                    
                    if (start != nil) {
                        if (start.agentPosition == end.agentPosition) {
                            msg = [NSString stringWithFormat:@"You selected %@'s edge", start.agentNameStr];
                        }else{
                            msg = [NSString stringWithFormat:@"You selected edge: %@ - %@", start.agentNameStr, end.agentNameStr];
                        }
                    }else
                        msg = nil;

                    [self.titleLabel setText:msg];  // display to title label
                    
                    [_drawToolsView setAgent:nil];          // update agent name input placeholder
                    [_drawToolsView setEdge:selectedEdge];  // update edge
                    [_drawToolsView setNeedsDisplay];
                    
                    
                  // * {{4.22 modify}}
                    [self updateCurrentCoalitionValue];
                    [self updateGameAreaViewValue];
                    [_gameAreaView setNeedsDisplay];
                   
                }
            }
        }
        
        // ** Delete selected path
        if (_isDeletePressed) {
            if (_agentsArray.count == 0) {  // _agentsArray is empty, alert
                UIAlertView *view =[[UIAlertView alloc] initWithTitle:@"Warning:" message:@"There is nothing to delete. Please create an agent node first." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [view show];
            }
            else{                          // agentsArray is not null
                BOOL isOnSegment = FALSE;
                NSDictionary *pathToRemove;
                
                // ONLY Delete one Path(Line) at a time
                
                for (int i = 0; i<_pathArray.count; i++) {
                    if (isOnSegment == FALSE) {
                        NSDictionary *path = _pathArray[i];
                        CGPoint startPoint = CGPointMake([path[STARTX] floatValue], [path[STARTY] floatValue]);
                        CGPoint endPoint = CGPointMake([path[ENDX] floatValue], [path[ENDY] floatValue]);
                        
                        if (CGPointEqualToPoint(startPoint, endPoint)) {
                            // Check point to circle arc
                            isOnSegment = [self isArcCircleWithAgentLocation:startPoint WithinDistance:5 fromPoint:touchPoint];
                            NSLog(@"TOUCHEND: delete the arc! Is it on the arc? %d", isOnSegment);

                        }else{ // Check point to line segment
                            isOnSegment = [self isLineSegmentWithPoint:startPoint andPoint:endPoint withinDistance:5 fromPoint:touchPoint];
                            NSLog(@"TOUCHEND:delete the path! Is it on the line? %d", isOnSegment);
                        
                        }
                        
                        if (isOnSegment == TRUE) {pathToRemove = path;}
                    }else
                        break;  // break the for loop
                }
                
                if (isOnSegment) {
                    // - delete the selected path in _pathArray
                    [_pathArray removeObject:pathToRemove];
                    // - delete the corresponding edge in _edgesArray
                    [self updateEdgesArrayByDeletePath:pathToRemove];
                    
 // {{4.22 modify}} // * update
                    [self updateCurrentCoalitionValue];
                    [self updateGameAreaViewValue];
                    

                    // - update gameAreaView
                    [_gameAreaView setNeedsDisplay];
                    // {{4.24 }}
                    [_gameTable reloadData];
                }
            }
        }
        
        // ** No function is selected. Recommend User to select dot function
        if (_isDotSelected == FALSE && _isDeletePressed == FALSE){
            NSLog(@"TOUCHEND: No function selected");
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reminding: " message:@"You can press dot button \n to create an agent." delegate:self cancelButtonTitle:@"OK, press dot now. " otherButtonTitles:nil, nil];
            [alert show];
            
        }
    }
}

//touchesCan- celled method is called if for some reason the operating system has to interrupt the application
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    if ([touch view] == [self gameAreaView]) {
//        [[self titleLabel] setText:@"Touch Cancelled"];
        NSLog(@"Touch cancelled");
    }
    
}

// ================================================================================
#pragma mark - Check distance a point to arc circle is within certain value
// ================================================================================
-(BOOL)isArcCircleWithAgentLocation:(CGPoint)agentLoc WithinDistance:(CGFloat)distance fromPoint:(CGPoint)touch{
    BOOL isWithinDistance = FALSE;
    CGPoint arcCircleCenter = CGPointMake(agentLoc.x+PAN+CIRCLE_RADIUS, agentLoc.y);
    
    double mincCircle = pow(CIRCLE_RADIUS-distance, 2);
    double maxCircle = pow(CIRCLE_RADIUS+distance, 2);
    double squareDistance = pow(touch.x-arcCircleCenter.x, 2) + pow(touch.y-arcCircleCenter.y, 2);
    
    if (squareDistance>=mincCircle && squareDistance<=maxCircle) {
        isWithinDistance = TRUE;
    }
    return isWithinDistance;
}

// ================================================================================
#pragma mark - Check distance a point to a line segment is within certain value
// ================================================================================
-(BOOL)isLineSegmentWithPoint:(CGPoint)a andPoint:(CGPoint)b withinDistance:(CGFloat)distance fromPoint:(CGPoint)c{
    BOOL isWithinDistance = FALSE;
    CGPoint v = CGPointMake(b.x-a.x, b.y-a.y);              // vector from a to b
    CGPoint w = CGPointMake(c.x-a.x, c.y-a.y);              // vectore from a to touchpoint
    CGFloat dotProductVW = v.x * w.x + v.y * w.y;           // dot product of vector v and w
    CGFloat squareLineLength = pow(v.x, 2) + pow(v.y, 2);   // square length of line segment
//    CGFloat dotProductVV = v.x * v.x + v.y * v.y;
    
    CGFloat d;
    // The angle between vector V and W is >= 90 degree
    if (dotProductVW <= 0) {
        // point c is near point a
        d = [self distanceBetweenPoint:c andPoint:a];
    }
    else if (dotProductVW >= squareLineLength){
        // point c is near point b
        d = [self distanceBetweenPoint:c andPoint:b];
    }
    else{
        CGFloat result = dotProductVW / squareLineLength;
        CGPoint nearestPoint = CGPointMake(a.x + result * v.x, a.y + result * v.y);
        d = [self distanceBetweenPoint:nearestPoint andPoint:c];
    }
    
    if (d <=distance) {
        isWithinDistance = TRUE;
    }
    return isWithinDistance;
}

/**
 Caculate the distance between 2 points
 **/
-(CGFloat)distanceBetweenPoint:(CGPoint)point1 andPoint:(CGPoint)point2{
    return sqrt(pow(point2.x-point1.x, 2) + pow(point2.y-point1.y, 2));
}




// ================================================================================
#pragma mark - Add new path to pathArray & Init edge object to edgesArray
// ================================================================================
// 4.9
-(void)addStartPoint:(CGPoint)startPoint andEndPoint:(CGPoint)endPoint{

    // * Init new path with given startPoint and endPoint
    NSMutableDictionary *newPath = [[NSMutableDictionary alloc] init];
    newPath[STARTX] = [NSString stringWithFormat:@"%f", startPoint.x];
    newPath[STARTY] = [NSString stringWithFormat:@"%f", startPoint.y];
    newPath[ENDX] = [NSString stringWithFormat:@"%f", endPoint.x];
    newPath[ENDY] = [NSString stringWithFormat:@"%f", endPoint.y];
    
    // * Check if the newPath does not exist in pathArray, then add it
    if (![_pathArray containsObject:newPath]) {
        [_pathArray addObject:newPath];
        
        // * Init edge object with given new path
        [self initEdgeWithPath:newPath];
    }
    
    [self printEdgesArray]; // print all edges
    [self printGameList];

}

//    NSDictionary *newwPath = @{
//                              STARTX: [NSString stringWithFormat:@"%f", startPoint.x],
//                              STARTY: [NSString stringWithFormat:@"%f", startPoint.y],
//                              ENDX: [NSString stringWithFormat:@"%f", endPoint.x],
//                              ENDY: [NSString stringWithFormat:@"%f", endPoint.y]
//                              };

-(void)printEdgesArray{
    for (Edge *e in _edgesArray) {
//    NSMutableArray *edges =[[NSMutableArray alloc] init];
//    edges = [_gameList[0] edgesArray];
//    for (Edge *e in edges) {

        //{{4.27}}
        NSLog(@"PRINT Coaliion EDGESARRAY: start agent: %@, end agent %@, weight value: %d",e.startAgent.agentNameStr, e.endAgent.agentNameStr, e.weightValue);
    }
}

-(void)printGameList{
    NSMutableArray *agents =[[NSMutableArray alloc] init];
    NSMutableArray *edges =[[NSMutableArray alloc] init];
    NSMutableArray *path =[[NSMutableArray alloc] init];

    for (Coalition *c in _gameList) {
        agents = c.agentsArray;
        edges = c.edgesArray;
        path  =c.pathsArray;
        
        NSLog(@"GameList: Print Coalitions");
        NSLog(@"Agents:");
        for (Agent *a in agents ) {
            NSLog(@"tag %d, name: %@, position: %@, %@", (int)a.index,a.agentNameStr, a.agentPosition,a.agentPosition);
        }
        
        NSLog(@"Edges:");
        for (Edge *e in edges) {
            
            //{{4.27}}
            NSLog(@"start agent: %@, end agent %@, weight value: %d",e.startAgent.agentNameStr, e.endAgent.agentNameStr, (int)e.weightValue);
        }
        NSLog(@"Paths:");
        NSLog(@"%@",path);
    }
}
// ==============================================================================
#pragma mark - Edges 1.init edge 2.delete edge by agent/path
// ==============================================================================

// Only update
-(void)initEdgeWithPath:(NSDictionary *)path{
    CGPoint startPoint = CGPointMake([path[STARTX] floatValue], [path[STARTY] floatValue]);
    CGPoint endPoint = CGPointMake([path[ENDX] floatValue], [path[ENDY] floatValue]);
    Agent *startAgent, *endAgent;
    
    for (Agent *a in _agentsArray) {
        
        CGPoint agentLocation = [[a agentPosition] CGPointValue];
        
        if (CGPointEqualToPoint(agentLocation, startPoint)) {
            startAgent = a;
        }
        
        if (CGPointEqualToPoint(agentLocation, endPoint)) {
            endAgent = a;
        }
    }
    
    int defaultValue = 2; // Set defalut edge weight to 2
    
    if (startAgent != nil && endAgent != nil) {
        Edge *e = [[Edge alloc] initWithStartAgent:startAgent endAgent:endAgent andValue:defaultValue];
        [_edgesArray addObject:e];
// {{modify 4.22}} DELETE ME!
        [self printEdgesArray];
        
  // {{Modify 4.21}}
        [self updateCurrentCoalitionValue];
        [self updateGameAreaViewValue];
        
//        [_coalition setEdgesArray:_edgesArray];
//        [_gameAreaView setEdgesArray:_edgesArray];
        
//        for (Edge *e in [_gameList[0] edgesArray]) {
//            NSLog(@"game list first coalition edges: %@", e.startAgent.agentNameStr);
//        }
//        [self printEdgesArray];
    }else
        NSLog(@"INIT Edge:!! Null Warning: One of agent is NULL !!!");

    // {{Modify 4.21}}
    [self printGameList];
}

#pragma mark Update coalition and gaemareview alll values
-(void)updateCurrentCoalitionValue{
    [_coalition setAgentsArray:_agentsArray];
    [_coalition setAgentViewsArray:_dotViewsArray];
    [_coalition setEdgesArray:_edgesArray];
    [_coalition setPathsArray:_pathArray];
    
}

-(void)updateGameAreaViewValue{
    [_gameAreaView setAgentsArray:_agentsArray];
    [_gameAreaView setAgentViewsArray:_dotViewsArray];
    [_gameAreaView setEdgesArray:_edgesArray];
    [_gameAreaView setPathArray:_pathArray];
}

-(Edge *)findEdgeByPath:(NSDictionary *)path{
    Edge *edge;
    
    CGPoint startPoint = CGPointMake([path[STARTX] floatValue], [path[STARTY] floatValue]);
    CGPoint endPoint = CGPointMake([path[ENDX] floatValue], [path[ENDY] floatValue]);
    Agent *startAgent, *endAgent;
    
    for (Agent *a in _agentsArray) {
        
        CGPoint agentLocation = [[a agentPosition] CGPointValue];
        
        if (CGPointEqualToPoint(agentLocation, startPoint)) {
//            NSLog(@"HI, start agent find");
            startAgent = a;
        }
        
        if (CGPointEqualToPoint(agentLocation, endPoint)) {
//            NSLog(@"HI, end agent find!");
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

-(void)updateEdgesArrayByDeleteAgent:(Agent *) agent{
    // Store need to be deleted edges
    NSMutableArray *edgesToRemove = [[NSMutableArray alloc] init];
    
    // Delete edges with agent as start/end
    for (Edge *e in _edgesArray) {
        if (e.startAgent == agent || e.endAgent == agent) {
            [edgesToRemove addObject:e];
        }
    }
    // If edgesToRemove is not empty
    if (edgesToRemove.count > 0) {
        for (Edge *e in edgesToRemove) {
            [_edgesArray removeObject:e]; // delete dege in edgesArray
        }
    }
    
    [self printEdgesArray]; // DELETE ME!!

}

-(void)updateEdgesArrayByDeletePath:(NSDictionary *)path{
    // Path startPOint and endPoint;
    CGPoint startPoint = CGPointMake([path[STARTX] floatValue], [path[STARTY] floatValue]);
    CGPoint endPoint = CGPointMake([path[ENDX] floatValue], [path[ENDY] floatValue]);
    
    // Delete edge with path as a line
    Edge *edgeToRemove;
    for (Edge *e in _edgesArray) {
        
        CGPoint startAgentLocation = [e.startAgent.agentPosition CGPointValue];
        CGPoint endAgentLocation = [e.endAgent.agentPosition CGPointValue];

        if (CGPointEqualToPoint(startAgentLocation, startPoint) && CGPointEqualToPoint(endAgentLocation, endPoint)) {
            NSLog(@"Remove path edge!");
            edgeToRemove = e;
        }
    }
    
    // Delete edge
    if (edgeToRemove) {
        [_edgesArray removeObject:edgeToRemove];
    }
    
    [self printEdgesArray]; // DELETE ME!!
}

// ========================================
#pragma mark - Load View in GameAreaView
// ========================================
-(void)loadView:(CGPoint) touchPoint
{
    // {{4.23 Ratio}}
    CIRCLE_RADIUS = [_gameAreaView getCircleRadius];    // get the circle radius
    PAN = [_gameAreaView getRatioPan];                  // get the pan distance
    
    // * 1. Positioning a view: agentDragger in superview: _gameAreaView
    AgentView *agentDragger =[[AgentView alloc] initWithFrame:CGRectMake(0, 0, 2 * CIRCLE_RADIUS, 2 * CIRCLE_RADIUS)];
    _tag = _tag+1;   // increase tag value by 1
    agentDragger.tag = _tag;            // give the view a unique tag
    agentDragger.center = CGPointMake(touchPoint.x, touchPoint.y); // set the UIView center to the postion point
    agentDragger.userInteractionEnabled = YES;  // Enable userInteraction
    agentDragger.backgroundColor = [UIColor whiteColor]; // set the background color
    agentDragger.layer.cornerRadius = CIRCLE_RADIUS;       // set the radius of corner
    agentDragger.layer.borderWidth = 1.5f;
    agentDragger.layer.masksToBounds = YES;     // like clipstoBounds of UIView- force all sub layers support this effect
    
    
    // * 2. Initialize agent with name and position ---- Use view.center as agent model location to update simutaneously
    Agent *agent = [[Agent alloc] initWithName:@"set name" withPosition:[NSValue valueWithCGPoint:agentDragger.center] andIndex:_tag];
    // * Add initialized agent to agentsArray
    [[self agentsArray] addObject:agent];
    
    // * Init agent model in agentDragger view
    [agentDragger setAgentM:agent];
    
//// DELETE ME!! Print AgentsArray
//    for (int i = 0; i<_agentsArray.count; i++) {
//        Agent *a = _agentsArray[i];
//        CGPoint x = [[_agentsArray[i] agentPosition] CGPointValue];
//        NSLog(@"* Array tag %d, name: %@, position: %.0f, %.0f", (int)a.index,a.agentNameStr, x.x,x.y);
//    }
    
    // * Pan
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [agentDragger addGestureRecognizer:panRecognizer];

    // * Tap
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [agentDragger addGestureRecognizer:singleFingerTap];
    
    //* Long Press Gesture and add it to agentDragger view
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognizer:)];
    [agentDragger addGestureRecognizer:longPress]; // add long press gesture to agentDragger View
    
    // * Add a subview to gameAreaView and update agentDragger and gameAreaView content
    [self.gameAreaView addSubview:agentDragger];
    [agentDragger setNeedsDisplay];
    
    [[self gameAreaView] setNeedsDisplay];
    
    // * 1.2 Add current dot view to dotViewArray
    [_dotViewsArray addObject:agentDragger];
    [_gameTable reloadData];

}
// ========================================
#pragma mark - Handle Pan Gesture
// ========================================
-(void)handlePan:(UIPanGestureRecognizer *) recognizer{
    
    NSInteger tag = recognizer.view.tag;    // get the view tag
    
    // * 1. Update view center location
    CGPoint touchPoint = [recognizer locationInView:_gameAreaView];
    recognizer.view.center = touchPoint;
    // {{4.24}}
    [_gameAreaView setNeedsDisplay];
    [_gameTable reloadData];

    // * 2.1 Find agent by index value = view.tag
    Agent *agent;   // store correspoding agent of selected view

    for (Agent *a in _agentsArray) {
        if (a.index == tag) {
            agent = a;
        }
    }
    
    // * 2.2 Update PathArray and update _gameAreaView
    CGPoint point = [agent.agentPosition CGPointValue];
    NSMutableDictionary *path = [[NSMutableDictionary alloc] init];
    for(path in _pathArray){
        CGPoint startPoint = CGPointMake([path[STARTX] floatValue], [path[STARTY] floatValue]);
        CGPoint endPoint = CGPointMake([path[ENDX] floatValue], [path[ENDY] floatValue]);
        
        NSString *newX = [NSString stringWithFormat:@"%f", recognizer.view.center.x];
        NSString *newY = [NSString stringWithFormat:@"%f", recognizer.view.center.y];
        
        if (startPoint.x == point.x && startPoint.y == point.y) {
            NSLog(@"Find path:");
            NSLog(@"%@",path);
            [path removeObjectForKey:STARTX];
            [path setValue:newX forKey:STARTX];
            [path removeObjectForKey:STARTY];
            [path setValue:newY forKey:STARTY];
            NSLog(@"start point match ! update the path! x %@, y %@", path[STARTX], path[STARTY]);
            NSLog(@"%@",path);
        }
        
        if (endPoint.x == point.x && endPoint.y == point.y) {
            NSLog(@"Find path:");
            NSLog(@"%@",path);
            [path removeObjectForKey:ENDX];
            [path setValue:newX forKey:ENDX];
            [path removeObjectForKey:ENDY];
            [path setValue:newY forKey:ENDY];
            NSLog(@"end point match ! Update the path! x %@, y %@", path[ENDX], path[ENDY]);
            NSLog(@"%@",path);
        }
        
        //{{4.24-second line}}
        [_gameAreaView setNeedsDisplay];
        [_gameTable reloadData];
    }
    
    // * 3. Update agent location by index:tag
    [agent updatePosition:[NSValue valueWithCGPoint:recognizer.view.center]];
    NSLog(@"agent finish update position");
    
    // * 4. Update path start point as the agent.agentPosiiton (find the agent whose index value = originally view tag) --- _pathStartPoint originally set in handleLongPress()
    for (Agent *a in _agentsArray) {
        if (a.index == _pathStartViewTag) {
            _pathStartPoint = [a.agentPosition CGPointValue];
        }
    }
    
}

// ================================================================================
#pragma mark - Handle Single Tap Gesture- 1. Delete agent and related paths 2. Set agent name
// ================================================================================
-(void)handleSingleTap:(UITapGestureRecognizer *)recognizer{
//    CGPoint location = [recognizer locationInView:[recognizer.view superview]];
    
    // * If delete button is pressed and agentsArray is not empty
    if (_isDeletePressed && _agentsArray.count != 0) {
        
        // 1. Delete selected view
        UIView *viewToRemove = recognizer.view;
        [viewToRemove removeFromSuperview];
        
        // 1.1 Delete the view in agentsViewArray
        [_dotViewsArray removeObject:viewToRemove];
        
        // 1.1 Find and Store need to be removed agent
        NSInteger index = recognizer.view.tag;    // get view tag
        Agent *agentToRemove;
        for (Agent *a in _agentsArray) {
            if (a.index == index) {
                agentToRemove = a;  // store agent need to be removed
            }
        }
        
        // 2. Delete all paths connectted with this view
        CGPoint location = recognizer.view.center;                      // store the view.center
        NSMutableArray *deletePaths = [[NSMutableArray alloc] init];    // store the paths need to be deleted
        NSMutableDictionary *path = [[NSMutableDictionary alloc] init]; // init the editable dic path
        for (path in _pathArray) {
            CGPoint startPoint = CGPointMake([path[STARTX] floatValue], [path[STARTY] floatValue]);
            CGPoint endPoint = CGPointMake([path[ENDX] floatValue], [path[ENDY] floatValue]);
            
            // 2.1 Store paths need to be deleted into deletePaths array
            if ((startPoint.x == location.x && startPoint.y == location.y)
                || (endPoint.x == location.x && endPoint.y == location.y)) {
                [deletePaths addObject:path];
            }
        }
        
        // 1.2 Delete corresponding agent in _agentsArray
        [_agentsArray removeObject:agentToRemove];
        
        // 2.2 Delete corresponding paths in _pathArray
        for (path in deletePaths) {
            [_pathArray removeObject:path];
        }
        
        // 3. Delete edges in _edgesArray
        [self updateEdgesArrayByDeleteAgent:agentToRemove];
        
        //{{4.22 modify}}
        [self updateCurrentCoalitionValue];
        [self updateGameAreaViewValue];
        [_gameAreaView setNeedsDisplay];    // update gameAreaView
        //{{4.24}}
        [_gameTable reloadData];
        
        // 5. update long press label & title label text to nil
        if (CGPointEqualToPoint(_pathStartPoint, [agentToRemove.agentPosition CGPointValue])) {
            [_longPressLabel setText:nil];
            [_titleLabel setText:nil];
        }

    }else{
        //** Allow user to set the name of agent
        NSLog(@"Set the agent Name!");
        Agent *a = [self findAgentWithIndexValueIs:recognizer.view.tag];
        
        // * dispaly selected agent name
        NSString *name = a.agentNameStr;
        NSString *msg = [NSString stringWithFormat:@"You selected agent %@", name];
        [self.titleLabel setText:msg];  // display to title label
        
        [_drawToolsView setEdge:nil];   // clear edge input
        [_drawToolsView setAgent:a];    // update agent input placeholder
        [_drawToolsView setNeedsDisplay];
    }
}

// ========================================
#pragma mark - Find agent with mathed index value
// ========================================
-(Agent *)findAgentWithIndexValueIs:(NSInteger)tag{
    Agent *agent;
    for (Agent *a in _agentsArray) {
        if (a.index == tag) {
            agent = a;
        }
    }
    return agent;
}

// ========================================
#pragma mark - Handle Long Press Gesture
// ========================================
-(IBAction)longPressGestureRecognizer:(id)sender{
    //* Get the location of the long press in the GameAreaView
    UILongPressGestureRecognizer *longPress = (UILongPressGestureRecognizer *)sender;
    UIGestureRecognizerState state = longPress.state;
    
    if (!_isDeletePressed) {
        UIView *myView = longPress.view;
        _pathStartViewTag = myView.tag;         // store the view tag
        
        _longPressLabel.lineBreakMode = YES;
        _longPressLabel.numberOfLines = 0;
        NSString *msg = @"";
        // * Update long press label
        for (Agent *a in _agentsArray) {
            if (a.index == myView.tag) {
                msg = [NSString stringWithFormat:@"Move Directions Tips:\n   (In Blue Area) \nDraw curve: move to agent %@ \nDraw line: move to target agent you want to connect.\n", a.agentNameStr];
                [_longPressLabel setText:msg];
            }
        }
        // * 2.1 Calcualte the label size based on message font size.
        CGSize labelSize = [msg sizeWithAttributes:@{NSFontAttributeName:_longPressLabel.font}];
        
        // * 2.2 Set label height as the calculated labelSize.height
        _longPressLabel.frame = CGRectMake(
                                           _longPressLabel.frame.origin.x, _longPressLabel.frame.origin.y,
                                           _longPressLabel.frame.size.width, labelSize.height);
        
        //* Animation here
        // 1. init the anim
        CABasicAnimation *transAnim = [CABasicAnimation alloc];
        transAnim.keyPath = @"transform.scale";
        transAnim.duration = .05f;//ANIMATION_DURATION;
        transAnim.repeatCount = 1; //ANIMATION_REPEAT;
        // toValue reach to point, byValue is increasing value in x,y axis, fromValue:move from which point
        transAnim.fromValue = [NSValue valueWithCGSize:CGSizeMake(.5, .5)];
        transAnim.toValue = [NSValue valueWithCGSize:CGSizeMake(1, 1)];
        
        // 2. add anim to layer
        [myView.layer addAnimation:transAnim forKey:@"transitionAnimation"];
        
        // {{4.9 store path}}
        // * 3. Set the view center point as start point of the line in gameAreaView
        _pathStartPoint = myView.center;
        
        [_gameTable reloadData];    // {{4.24}}
    }else{
        if (state == UIGestureRecognizerStateEnded) {
            NSLog(@"Long Press Detected");
            //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Gesture" message:@"Long Press Detected" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            //        [alert show];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Sorry, You are in delete function. You cannot draw path now." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
}


// ========================================
#pragma mark - Table View
// ========================================
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
//    return 2;
    return [_gameList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //* 1.1 Dispaly the table title
    if (_gameList.count > 0) {
        [_gameListTitleLabel setText:@"Game History"];
    }
    
    //* 1.2 Display title of game history table
    static NSString *CellIdentifier = @"gameCell";
    GameCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    [[cell gameCellTitle] setText:[NSString stringWithFormat:@"Coalition %zd", indexPath.row+1]];

    //* 2. Set cell gameAreaView Value
    Coalition *c = [_gameList objectAtIndex:indexPath.row];
    
    //* 3. Get the ratio of cell gameAreaView.width with standard width
    CGFloat cellRatio = [cell.gameAreaView getRatio];
    
    //{{4.23 ratio}} 4.1 Remove previous agent dot views
    // Fix the problem with pan bug: display many dot views when pan
    [cell.gameAreaView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    // * 4.2 Generate resized agent dot Views array
    NSMutableArray *cellDotViewsArray = [[NSMutableArray alloc] init];
    cellDotViewsArray = [self createCellDotsViewsArrayByGameAreaViewAgentViewsArray:c.agentViewsArray andAgentsArray:c.agentsArray withCellRatio:cellRatio];
//    NSLog(@"Cell dot views Array: %@", cellDotViewsArray);
    
    // * 4.3 Update cell.gameAreaView
    [[cell gameAreaView] setAgentsArray:c.agentsArray];
    [[cell gameAreaView] setAgentViewsArray:cellDotViewsArray];
    [[cell gameAreaView] setEdgesArray:c.edgesArray];
    [[cell gameAreaView] setPathArray:c.pathsArray];
    
    // * 4.4 Add subviews to cell gameAreaView
    for (AgentView *v in [cell.gameAreaView agentViewsArray]) {
        [cell.gameAreaView addSubview:v];
    }
    
    [cell.gameAreaView setNeedsDisplay];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //* 1. Update button function !!
    _isDotSelected = TRUE;                  // Default status is in drawing section
    _isDeletePressed = FALSE;
    [self updateFunctionRemind];
    
    [_longPressLabel setText:nil];          // update long press label
    _pathStartPoint = CGPointMake(0,0);     // update no long pressed agent
    
    
    // * Update property set view
    [_drawToolsView setAgent:nil];
    [_drawToolsView setEdge:nil];
    [_drawToolsView setNeedsDisplay];
    
    
    //{{4.23-cell select}} * Clear game area view all subviews
    [_gameAreaView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    // * Get the selected row's coalition
    _coalition = [_gameList objectAtIndex:indexPath.row];
    
    _agentsArray = _coalition.agentsArray;
    _dotViewsArray = _coalition.agentViewsArray;
    _edgesArray = _coalition.edgesArray;
    _pathArray = _coalition.pathsArray;
    
    Agent *lastAgent = [_agentsArray lastObject];
    _tag = lastAgent.index;                     // {{4.27}} Update tag to last created agent.index
    
    NSLog(@"Cell did select");
    // DELETE ME
//    [_gameListTitleLabel setText:[NSString stringWithFormat:@"Tag now: %d",_tag]];
    for (Agent *a in _agentsArray) {
        NSLog(@"!!!!Agent %@ tag: %d", a.agentNameStr, (int)a.index);
    }

    
    
    [_gameAreaView setAgentsArray:_coalition.agentsArray];
    [_gameAreaView setAgentViewsArray:_coalition.agentViewsArray];
    [_gameAreaView setEdgesArray:_coalition.edgesArray];
    [_gameAreaView setPathArray:_coalition.pathsArray];
    
    // * Add subviews back to view
    for (AgentView *v in _coalition.agentViewsArray) {
        [_gameAreaView addSubview:v];
    }
    
    [_gameAreaView setNeedsDisplay];
}

#pragma mark - generte Cell's agentViewsArray
-(NSMutableArray *)createCellDotsViewsArrayByGameAreaViewAgentViewsArray:(NSMutableArray *)agentViewsArray
                                                          andAgentsArray:(NSMutableArray *)agentsArray
                                                           withCellRatio:(CGFloat)ratio{
    NSMutableArray *cellDotViewsArray = [[NSMutableArray alloc] init];
    
    for (AgentView *v in agentViewsArray) {
        CGPoint location = CGPointMake(v.center.x * ratio, v.center.y *ratio);
        NSInteger tag = v.tag;
        AgentView *cellDot = [[AgentView alloc] initWithFrame:CGRectMake(0, 0, 2 * CIRCLE_RADIUS * ratio, 2 * CIRCLE_RADIUS * ratio)];
        cellDot.center = location;
        cellDot.tag = tag;
        cellDot.backgroundColor = [UIColor whiteColor]; // set the background color
        cellDot.layer.cornerRadius = CIRCLE_RADIUS * ratio;       // set the radius of corner
        cellDot.layer.borderWidth = 1.5f;
        cellDot.layer.masksToBounds = YES;
        
        for (Agent *a in agentsArray) {
            if (a.index == tag) {
                [cellDot setAgentM:a];
            }
        }
        [cellDotViewsArray addObject:cellDot];
    }
    return cellDotViewsArray;
}

@end


// If cross product of (b-a) and (c-a) is 0, then the point is on the line

//    CGFloat crossProduct = (b.x-a.x)*(c.y-a.y) - (c.x-a.x)*(b.y-a.y);
//    if (crossProduct != 0) {
//        return FALSE;
//    }
//
//    // If min(a.x,b.x)<=c.x <=max(a.x,b.x) and min(a.y,b.y)<=c.y<=max(a.y,b.y), then c is on the segment
//    if (!(c.x >= MIN(a.x, b.x) && c.x <=MAX(a.x, b.x))
//        && (c.y <= MAX(a.y,b.y) && c.y >= MIN(a.y, b.y))
//        ) {
//        return FALSE;
//    }

// * Initialise the agentDragger Image view
//    DragView *agentDragger = [[DragView alloc] initWithImage:[UIImage imageNamed:@"yellowCounter"]];
//    _agentDragger = [[DragView alloc] initWithFrame:CGRectMake(10, 10, 50, 50)];
//    [_agentDragger setName:@"p"];
//
//    [_agentDragger setIsLongPressed:NO];
//    [_agentDragger setIsPressed:NO];
//    [_agentDragger setFrame:CGRectMake(5, 5, 50, 50)];
//     NSLog(_agentDragger.name, _agentDragger.isLongPressed);

// Remove view

//    for (int i = 0; i<_agentsArray.count; i++) {
//        if ([_agentsArray[i] selected]) {
//            for (UIView *viewRef in _gameAreaView.subviews) {
//                UIView *viewToRemove = [viewRef viewWithTag:i];
//                NSLog(@"remove view tag : %d", (int)viewToRemove.tag);
//                [viewToRemove removeFromSuperview];
//            }
//        }
//    }


//-(CGFloat)distanceToPoint:(CGPoint) point fromLineSegmentStartPoint:(CGPoint)start andEndPoint:(CGPoint)end{
//    CGPoint dSP = CGPointMake(start.x-point.x, start.y-point.y);    // vector start-point
//    CGPoint dSE = CGPointMake(end.x-start.x, end.y-start.y);        // vector start-end
//    CGFloat dot = dSP.x * dSE.x + dSP.y * dSE.y;
//    CGFloat length_sqr = pow(dSE.x, 2) + pow(dSE.y, 2);
//
//    CGFloat param = dot / length_sqr;
//    CGFloat xx, yy;
//    if (param < 0 || (start.x == end.x && start.y == end.y)) {
//        //
//        xx = start.x;
//        yy = start.y;
//    }else if (param > 1){
//        xx = end.x;
//        yy = end.y;
//    }else{
//        xx = start.x + param * dSE.x;
//        yy = start.y + param * dSE.y;
//    }
//
//    CGFloat dx = point.x - xx;
//    CGFloat dy = point.y - yy;
//
//    CGFloat distance = sqrtf(pow(dx, 2) + pow(dy, 2));
//
//    return distance;
//}


//check which agent dot is selected
//            for (int i = 0; i<_agentsArray.count; i++) {
//                CGPoint agentLocation = [[_agentsArray[i] agentPosition] CGPointValue];
////                double x = fabs(touchPoint.x - agentLocation.x);
////                double y = fabs(touchPoint.y - agentLocation.y);
////                if (pow(x, 2) + pow(y, 2) <= pow(CIRCLE_RADIUS, 2)) {
////                    UIView *viewToRemove = [_gameAreaView viewWithTag:i];
////                    [viewToRemove removeFromSuperview];
////                }
////                if ([_agentsArray[i] selected]) {
////                    UIView *viewToRemove = [_gameAreaView viewWithTag:i];
////                    [viewToRemove removeFromSuperview];
////                }
//            }
