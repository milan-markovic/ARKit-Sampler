//
//  PlaneManager.m
//  ARKit-Sampler
//
//  Created by Milan Markovic on 4/12/18.
//  Copyright © 2018 Shuichi Tsutsumi. All rights reserved.
//

#import "SceneNodeManager.h"
#import "GamificationManager.h"

const int32_t FEATURE_POINTS_COUNT_TRESHOLD = 50;

const int32_t SCENE_UPDATE_INTERVAL = 200; //ms

@interface NodeData : NSObject
@property int gamified;

@end

@implementation SceneNodeManager  {
    NSMutableDictionary<NSUUID*, NSDictionary*>* nodes;
    NSMutableDictionary<NSUUID*, NodeData*>* nodeData;
    
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
        nodes = [[NSMutableDictionary alloc] init];
        nodeData = [[NSMutableDictionary alloc] init];
        
        featurePoints = [[NSMutableDictionary alloc] init];
        featurePointsBuffer = [[NSMutableDictionary alloc] init];
        
        debugMode = 1;
        
        progress = 0;
        step = 100;
        lastStep = 0;
        
        featurePointsCounter = 0;
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
    [nodes removeObjectForKey:anchor.identifier];
    
}
- (void)renderer:(id<SCNSceneRenderer>)renderer didAddNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
    ARPlaneAnchor* planeAnchor = (ARPlaneAnchor*)anchor;
    NSDictionary* group = [NSDictionary dictionaryWithObjects:@[node, planeAnchor] forKeys:@[@"node", @"planeAnchor"]];
    [nodes setObject:group forKey:anchor.identifier];
    NSLog(@"didAddNode");
    
    
    
    if(debugMode){
        
    }
}

- (void)renderer:(id<SCNSceneRenderer>)renderer updateAtTime:(NSTimeInterval)time {
    if(!lastUpdateAtTime){
        lastUpdateAtTime = time;
    }
    if(lastUpdateAtTime + SCENE_UPDATE_INTERVAL < time) {
        GamificationInputType inputType = [[GamificationManager sharedManager] handleUpdate];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self handleGamificationInput:inputType];
        });
    }
}

#pragma mark - ARSessionDelegate methods

- (void)session:(ARSession *)session didUpdateFrame:(ARFrame *)frame {
    ARPointCloud* rawFeaturePoints = frame.rawFeaturePoints;
//    [self handleFeaturePoints:rawFeaturePoints];
}


#pragma mark - private methods


-(void) handleGamificationInput:(GamificationInputType) inputType{
    switch (inputType) {
        case INPUT_TYPE_USE_PLANES:
            [self addGamificationInput];
            break;
        case INPUT_TYPE_USE_AIR:
            [self addGamificationInputForVector:SCNVector3Zero];
        default:
            break;
    }
}

-(void) addGamificationInput{
    SCNVector3 vector = SCNVector3Zero;
    //find node
    for (NodeData* data in nodeData) {
        if(data.gamified == 0){
            NSUUID* uuid = [nodeData allKeysForObject:data][0];
            ARPlaneAnchor* planeAnchor = (ARPlaneAnchor*)[[nodes objectForKey:uuid] objectForKey:@"planeAnchor"];
            
            vector_float3 center = [planeAnchor center];
            vector = SCNVector3FromFloat3(center);
            break;
        }
    }
    [self addGamificationInputForVector:vector];
}

-(void) addGamificationInputForVector:(SCNVector3)vector{
    if(SCNVector3EqualToVector3(SCNVector3Zero, vector)){
        //find random location
        SCNVector3 newVector = SCNVector3Make(rand()*3, rand()*3, (rand()*5) + 1);
        [self addScene:[self getSceneModelForGamification] forVector:newVector];
    } else {
        [self addScene:[self getSceneModelForGamification] forVector:vector];
    }
}


-(void) addScene:(SCNScene*) scene forVector:(SCNVector3)vector{
    SCNNode* node = [[SCNNode alloc] init];
    [node addChildNode:[scene rootNode]];
    node.position = vector;
    [sceneView.scene.rootNode addChildNode:node];
}

-(SCNScene*) getSceneModelForGamification{
    SCNScene* duck = [SCNScene sceneNamed:@"duck.scn" inDirectory:@"models.scnassets/duck" options:nil];
    return duck;
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
            NSLog(@"didnt draw point");
            //[[[[node geometry] firstMaterial] diffuse] setContents:[UIColor colorWithRed:0.1 green:0.3 blue:0.8 alpha:1]];
        }
        
    } else {
        if(debugMode){
            [sceneView.scene.rootNode addChildNode:[self getNodeForFeaturePoint:point]];
        }
        if([featurePointsBuffer count] > FEATURE_POINTS_COUNT_TRESHOLD) {
            [featurePoints addEntriesFromDictionary:featurePointsBuffer];
            [self analyzeFeaturePoints];
            [featurePointsBuffer removeAllObjects];
        } else {
            [featurePointsBuffer setObject:[NSValue valueWithPointer:&point] forKey:@(identifier)];
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
