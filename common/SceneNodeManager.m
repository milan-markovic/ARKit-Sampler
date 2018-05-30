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

@implementation SceneNodeManager  {
    NSMutableDictionary<NSUUID*, NSDictionary*>* nodes;
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
    
    SCNScene* duck = [SCNScene sceneNamed:@"duck.scn" inDirectory:@"models.scnassets/duck" options:nil];
    [node addChildNode:[duck rootNode]];
    
    if(debugMode){
        
    }
}

- (void)renderer:(id<SCNSceneRenderer>)renderer updateAtTime:(NSTimeInterval)time {
    if(!lastUpdateAtTime){
        lastUpdateAtTime = time;
    }
    if(lastUpdateAtTime + SCENE_UPDATE_INTERVAL < time) {
        [[GamificationManager sharedManager] handleUpdate:nodes];
    }
}

#pragma mark - ARSessionDelegate methods

- (void)session:(ARSession *)session didUpdateFrame:(ARFrame *)frame {
    ARPointCloud* rawFeaturePoints = frame.rawFeaturePoints;
//    [self handleFeaturePoints:rawFeaturePoints];
}


#pragma mark - private methods

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

/*
 extension ARPlaneAnchor {
 
 @discardableResult
 func addPlaneNode(on node: SCNNode, geometry: SCNGeometry, contents: Any) -> SCNNode {
 guard let material = geometry.materials.first else { fatalError() }
 
 if let program = contents as? SCNProgram {
 material.program = program
 } else {
 material.diffuse.contents = contents
 }
 
 let planeNode = SCNNode(geometry: geometry)
 
 DispatchQueue.main.async(execute: {
 node.addChildNode(planeNode)
 })
 
 return planeNode
 }
 
 func addPlaneNode(on node: SCNNode, contents: Any) {
 let geometry = SCNPlane(width: CGFloat(extent.x), height: CGFloat(extent.z))
 let planeNode = addPlaneNode(on: node, geometry: geometry, contents: contents)
 planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2.0, 1, 0, 0)
 }
 
 func findPlaneNode(on node: SCNNode) -> SCNNode? {
 for childNode in node.childNodes {
 if childNode.geometry as? SCNPlane != nil {
 return childNode
 }
 }
 return nil
 }
 
 func updatePlaneNode(on node: SCNNode) {
 DispatchQueue.main.async(execute: {
 guard let plane = self.findPlaneNode(on: node)?.geometry as? SCNPlane else { return }
 guard !PlaneSizeEqualToExtent(plane: plane, extent: self.extent) else { return }
 
 plane.width = CGFloat(self.extent.x)
 plane.height = CGFloat(self.extent.z)
 })
 }
 }
 
 fileprivate func PlaneSizeEqualToExtent(plane: SCNPlane, extent: vector_float3) -> Bool {
 if plane.width != CGFloat(extent.x) || plane.height != CGFloat(extent.z) {
 return false
 } else {
 return true
 }
 }
 */

@end
