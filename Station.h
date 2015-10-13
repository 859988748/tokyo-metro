//
//  Station.h
//  tokyo-metro
//
//  Created by llch on 15/10/12.
//  Copyright © 2015年 llch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Node.h"
@class Node;

@interface Station : NSObject
@property(strong) NSString * name;
@property(strong) NSString * stationId;
@property(strong) NSMutableDictionary * nodeMap;
@property(strong) NSMutableArray * nodes;
-(instancetype) initWithSting:(NSString *)id Name:(NSString *)name;
-(Node *)setNodeArriveTime:(int)arriveTime routId:(int)routeId tripId:(int)tripId;
-(int)getNodeCount;
-(Node *)getNode:(int) index;
-(int)getTransTimeFrom:(int) route_from To:(int) rout_to;
-(void)selfLink;
-(void)setUpinit;
-(Node *)getBestNode;
@end
