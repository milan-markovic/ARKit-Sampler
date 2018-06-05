//
//  PlaneManager.m
//  ARKit-Sampler
//
//  Created by Milan Markovic on 4/12/18.
//  Copyright © 2018 Shuichi Tsutsumi. All rights reserved.
//

#import "SceneNodeManager.h"
#import "GamificationManager.h"
#import "GamificationObjectRepository.h"
#import "GamificationAnchorRepository.h"
#import "GamificationDataRepository.h"
#import "GamificationModel.h"


const int32_t FEATURE_POINTS_COUNT_TRESHOLD = 50;

const int32_t SCENE_UPDATE_INTERVAL = 2; //sec




@implementation SceneNodeManager  {
    NSMutableArray<id<EventObjectObserver>>* observers;
    
    
    
    NSMutableDictionary<NSNumber*, NSValue*>* featurePoints;
    NSMutableDictionary<NSNumber*, NSValue*>* featurePointsBuffer;
    
    int32_t debugMode;
    
    uint64_t progress;
    uint64_t step;
    uint64_t lastStep;
    
    int32_t featurePointsCounter;
    
    NSTimeInterval lastUpdateAtTime;
      
    
}

@synthesize sceneView;

#pragma mark Singleton Methods

+ (id)sharedManager {
    static SceneNodeManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        
        featurePoints = [[NSMutableDictionary alloc] init];
        featurePointsBuffer = [[NSMutableDictionary alloc] init];
        
        observers = [NSMutableArray new];
        
        debugMode = 1;
        
        progress = 0;
        step = 100;
        lastStep = 0;
        
        featurePointsCounter = 0;
        
        [[GamificationManager sharedManager] registerInputObserver:self];
        [[GamificationManager sharedManager] registerOutputObserver:self];
    }
    return self;
}



#pragma mark - SceneViewDelegate methods

- (void)renderer:(id<SCNSceneRenderer>)renderer willRenderScene:(SCNScene *)scene atTime:(NSTimeInterval)time {
    
}
- (void)renderer:(id<SCNSceneRenderer>)renderer didRenderScene:(SCNScene *)scene atTime:(NSTimeInterval)time {
    
}
- (void)renderer:(id<SCNSceneRenderer>)renderer willUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
    
}
- (void)renderer:(id<SCNSceneRenderer>)renderer didUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
    
}
- (void)renderer:(id<SCNSceneRenderer>)renderer didRemoveNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
    NSLog(@"didRemoveNode");
    [GamificationAnchorRepository removeNode:anchor.identifier];
    
}
- (void)renderer:(id<SCNSceneRenderer>)renderer didAddNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
    ARPlaneAnchor* planeAnchor = (ARPlaneAnchor*)anchor;
    [GamificationAnchorRepository setNode:node andAnchor:planeAnchor forKey:planeAnchor.identifier];
    NSLog(@"didAddNode");
}

- (void)renderer:(id<SCNSceneRenderer>)renderer updateAtTime:(NSTimeInterval)time {
    //NSLog(@"updateAtTime %lf", time);
    if(!lastUpdateAtTime){
        lastUpdateAtTime = time;
    }
    if(lastUpdateAtTime + SCENE_UPDATE_INTERVAL < time) {
        [[GamificationManager sharedManager] handleUpdate];
        lastUpdateAtTime = time;
    }
}

#pragma mark - ARSessionDelegate methods

- (void)session:(ARSession *)session didUpdateFrame:(ARFrame *)frame {
    //ARPointCloud* rawFeaturePoints = frame.rawFeaturePoints;
    //[self handleFeaturePoints:rawFeaturePoints];
}

#pragma mark - InputEventObserver methods

- (void) onInputEvent:(NSUUID*) eventId type:(GamificationInputType)inputType{
    [self handleInputEvent:eventId type:inputType];
}

#pragma mark - OutputEventObserver methods

-(void) onOutputEvent:(NSUUID *)eventId{
    [self handleOutputEvent:eventId];
}


#pragma mark - public methods

-(void) registerEventObjectObserver:(id<EventObjectObserver>) observer{
    [observers addObject:observer];
}

-(void) notifyObservers:(NSUUID*) eventId{
    for (id<EventObjectObserver> observer in observers) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            @try{
                [observer onEventObjectClick:eventId];
            } @catch(NSException* e){
                NSLog(@"Exception occured in observer: %@" , [e description]);
            }
        });
    }
}

#pragma mark - Touch observer

-(void) touchesBegan:(NSSet<UITouch*>*)touches with:(UIEvent*) event{
    UITouch* touch = [touches allObjects][0];
    CGPoint touchLocation = [touch locationInView:sceneView];
    
    NSArray<SCNHitTestResult*>* results = [sceneView hitTest:touchLocation options:nil];
    for (SCNHitTestResult* hitResult in results) {
        SCNNode* hitNode = [hitResult node];
        for (NSUUID* uuid in [GamificationObjectRepository getAll]) {
            SCNNode* eventNode = [GamificationObjectRepository getGamificationNodeForId:uuid];
            for (SCNNode* childNode in [eventNode childNodes]) {
                if(childNode == hitNode){
                    [self handleEventNodeTouch:uuid];
                }
            }
        }
    }
    
}


#pragma mark - private methods

-(void) handleEventNodeTouch:(NSUUID*) uuid{
    NSLog(@"duck touch %@", uuid);
    
    [self notifyObservers:uuid];
}

-(void) handleOutputEvent:(NSUUID*)eventId {
    NSLog(@"handleOutputEvent %@", eventId);
    SCNNode* node = [GamificationObjectRepository getGamificationNodeForId:eventId];
    NSLog(@"handleOutputEvent node %@", node);
    [node removeFromParentNode];
}

-(void) handleInputEvent:(NSUUID*)eventId type:(GamificationInputType) inputType{
    SCNNode* node;
    switch (inputType) {
        case INPUT_TYPE_USE_PLANES:
            node = [self addGamificationInput];
            break;
        case INPUT_TYPE_USE_AIR:
            node = [self addGamificationInputForVector:SCNVector3Zero];
        default:
            break;
    }
    
    if(node != nil){
        [GamificationObjectRepository setGamificationNode:node forId:eventId];
    }
}

-(SCNNode*) addGamificationInput{
    NSLog(@"addGamificationInput");
    SCNVector3 vector = SCNVector3Zero;

    NSUUID* uuid = [GamificationAnchorRepository getAvailableAnchorIdentifier];
    if(uuid != nil){
        GamificationAnchorEntry* anchorEntry = [GamificationAnchorRepository getEntryForIdentifier:uuid];
        GamificationDataEntry* dataEntry;
        if((dataEntry = [GamificationDataRepository getEntryForIdentifier:uuid]) == nil){
            dataEntry = [GamificationDataEntry new];
            dataEntry.gamified = 1;
            [GamificationDataRepository setEntry:dataEntry ForIdentifier:uuid];
        } else {
            dataEntry.gamified = 1;
        }
        
        vector = [anchorEntry getSCNVector3Location];
    }
    
    return [self addGamificationInputForVector:vector];
}

-(SCNNode*) addGamificationInputForVector:(SCNVector3)vector{
    NSLog(@"handleGamificationInput %f %f %f", vector.x, vector.y, vector.z);
    if(SCNVector3EqualToVector3(SCNVector3Zero, vector)){
        //find random location
        int i = 0;
        int lowerBound = 0;
        unsigned long upperBound = [featurePoints count];
        int rndValue = lowerBound + arc4random() % (upperBound - lowerBound);
        unsigned int objNo = rndValue;
        SCNVector3 point = SCNVector3Zero;
        for (NSNumber* identifier in featurePoints) {
            i++;
            if(i == objNo) {
                NSValue *value = featurePoints[identifier] ;
                [value getValue:&point];
                break;
            }
        }
        SCNVector3 newVector;
        if(!SCNVector3EqualToVector3(SCNVector3Zero, point)){
            newVector  = point;
        } else {
            newVector = SCNVector3Make([self randomFloatBetween:0 and:2] - 1, [self randomFloatBetween:0 and:2] - 1, [self randomFloatBetween:0 and:2] - 1);
        }
        
        return [self addScene:[self getNodeModelForGamification] forVector:newVector];
    } else {
        return [self addScene:[self getNodeModelForGamification] forVector:vector];
    }
}


-(SCNNode*) addScene:(SCNNode*) node forVector:(SCNVector3)vector{
    
    node.position = vector;
    [sceneView.scene.rootNode addChildNode:node];
//    [sceneView.scene.rootNode addAnimation:[SCNAnimation animationWithCAAnimation:animation] forKey:@"bottle"];
    return node;
}

-(SCNNode*) getNodeModelForGamification{
    return [GamificationModel new];
}


- (float)randomFloatBetween:(float)smallNumber and:(float)bigNumber {
    float diff = bigNumber - smallNumber;
    return (((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * diff) + smallNumber;
}

#pragma mark - Feature points

-(void) handleFeaturePoints: (ARPointCloud*) rawFeaturePoints{
    int64_t count = rawFeaturePoints.count;
    const vector_float3 *points = rawFeaturePoints.points;
    
    for (int i = 0; i< count; i++) {
        SCNVector3 pointV = SCNVector3FromFloat3(points[i]);
        [self addFeaturePoint:pointV withIdentifier:rawFeaturePoints.identifiers[i]];
    }
}



-(void) addFeaturePoint: (SCNVector3) point withIdentifier:(const uint64_t) identifier{
    if(([featurePoints objectForKey:@(identifier)]) || ([featurePointsBuffer objectForKey:@(identifier)])
       //check if same point exists, O(n) ?!
       ){
        //dont draw point
        if(debugMode){
            //NSLog(@"didnt draw point");
            //[[[[node geometry] firstMaterial] diffuse] setContents:[UIColor colorWithRed:0.1 green:0.3 blue:0.8 alpha:1]];
        }
        
    } else {
        if(debugMode){
            //[sceneView.scene.rootNode addChildNode:[self getNodeForFeaturePoint:point]];
        }
        if([featurePointsBuffer count] > FEATURE_POINTS_COUNT_TRESHOLD) {
            [featurePoints addEntriesFromDictionary:featurePointsBuffer];
            //[self analyzeFeaturePoints];
            [featurePointsBuffer removeAllObjects];
        } else {
            NSValue *value = [NSValue valueWithBytes:&point objCType:@encode(SCNVector3)];
            [featurePointsBuffer setObject:value forKey:@(identifier)];
            NSLog(@"%05f, %05f, %05f", point.x, point.y, point.z);
        }
        
    }
    

}

-(SCNNode*) getNodeForFeaturePoint: (SCNVector3) point{
    
    SCNSphere* sphere = [SCNSphere sphereWithRadius:0.01];
    [[[sphere firstMaterial] diffuse] setContents:[UIColor colorWithRed:1 green:153/255 blue:83/255 alpha:1]];
    [[sphere firstMaterial] setLightingModelName:SCNLightingModelConstant];
    
    SCNNode* node = [SCNNode nodeWithGeometry:sphere];
    node.position = point;
    return node;
}


-(void) updateProgressWith:(int16_t) progressValue {
    progress += progressValue;
    
    if(progress % step > lastStep) {
        lastStep = progress % step;
        [self notifyProgress];
    }
}

-(void) notifyProgress {
    //TODO: notify observers
    
    //process featurePoints;
    
    //find bulks
}

-(void) analyzeFeaturePoints {
    for (NSNumber* identifier in featurePointsBuffer) {
        SCNVector3 featurePointFromBuffer = *((SCNVector3*)[featurePointsBuffer[identifier] pointerValue]);
        for (NSNumber* identifier2 in featurePoints) {
            SCNVector3 featurePoint1 = *((SCNVector3*)[featurePoints[identifier2] pointerValue]);
            for (NSNumber* identifier3 in featurePoints) {
                SCNVector3 featurePoint2 = *((SCNVector3*)[featurePoints[identifier3] pointerValue]);

                //calculate plane
                GLKVector3 v1 = GLKVector3Make(featurePoint2.x - featurePointFromBuffer.x, featurePoint2.y - featurePointFromBuffer.y, featurePoint2.z - featurePointFromBuffer.z);
                GLKVector3 v2 = GLKVector3Make(featurePoint1.x - featurePointFromBuffer.x, featurePoint1.y - featurePointFromBuffer.y, featurePoint1.z - featurePointFromBuffer.z);
                
                GLKVector3 crossProduct = GLKVector3Multiply(v1, v2);
                
                double_t w = crossProduct.x*featurePointFromBuffer.x + crossProduct.z*featurePointFromBuffer.z + crossProduct.y*featurePointFromBuffer.y;
                
                GLKVector4 plane = GLKVector4Make(crossProduct.x, crossProduct.y, crossProduct.z, w);
                
                //check if plane is at least slightly horizontal
                NSLog(@"%05f, %05f, %05f, %05f", plane.x, plane.y, plane.z, plane.w);
                
            }
        }
    }
}


@end
