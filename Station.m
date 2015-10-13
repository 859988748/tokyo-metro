//
//  Station.m
//  tokyo-metro
//
//  Created by llch on 15/10/12.
//  Copyright © 2015年 llch. All rights reserved.
//

#import "Station.h"

@interface Station ()
{
    int _transTime;
}

@end

@implementation Station

-(instancetype) initWithSting:(NSString *)station_id Name:(NSString *)name{
    self = [super init];
    if (self){
        _name = [NSString stringWithString:name];
        _stationId = [NSString stringWithString:station_id];
        _transTime = 100;
        _nodeMap = [[NSMutableDictionary alloc] initWithCapacity:0];
        _nodes = [[NSMutableArray alloc]  initWithCapacity:0];
    }
    return  self;
}
-(Node *)setNodeArriveTime:(int)arriveTime routId:(int)routeId tripId:(int)tripId{
    long key = arriveTime * 50000 + tripId;
    Node * node  = [_nodeMap objectForKey:[NSNumber numberWithLong:key]];
    if (node == nil) {
        node = [[Node alloc] initWithStationg:self Time:arriveTime routeId:routeId tripId:tripId];
        [_nodeMap setObject:node forKey:[NSNumber numberWithLong:key]];
    }
    return node;
}
-(int)getNodeCount{
    return (int)_nodes.count;
}
-(Node *)getNode:(int) index{
    return [_nodes objectAtIndex:index];
}
-(int)getTransTimeFrom:(int) route_from To:(int) rout_to{
    if (route_from == rout_to) {
        return 0;
    }
    return _transTime;
}
-(void)selfLink{
    NSArray * keys = [_nodeMap allKeys];
    NSArray * sortedKeys = [keys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        long key1 = [obj1 longValue];
        long key2 = [obj1 longValue];
        if (key1 > key2) {
            return NSOrderedDescending;
        }
        if (key1 < key2) {
            return NSOrderedAscending;
        }
        return NSOrderedSame;
    }];
    [_nodes removeAllObjects];
    for (id key in sortedKeys) {
        [_nodes addObject:[_nodeMap objectForKey:key]];
    }
    NSMutableOrderedSet * routes = [[NSMutableOrderedSet alloc] initWithCapacity:0];
    for (int i = 0; i < _nodes.count; i ++) {
        [routes addObject:[NSNumber numberWithInt:((Node *)_nodes[i]).routeId]];
    }
    [routes sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        int n1 = [obj1 intValue];
        int n2 = [obj2 intValue];
        if (n1 > n2) {
            return NSOrderedDescending;
        }
        if (n1 < n2) {
            return NSOrderedAscending;
        }
        return NSOrderedSame;
    }];
    if ([_name isEqualToString:@"大手町"]) {
        NSLog(@"大手町routs count:%lu",(unsigned long)[routes count]);
    }
    for (int i = 0 ; i < _nodes.count; i ++) {
        Node * from = _nodes[i];
        for (NSNumber * routNumber in routes) {
            int rout = [routNumber intValue];
            int trans = [self getTransTimeFrom:from.routeId To:rout];
            for (int j = 0; j < _nodes.count; j++) {
                Node * to = _nodes[j];
                if (to.routeId == rout) {
                    if (to.time > (from.time + trans)) {
                        [Node linkfrom:from To:to];
                        break;
                    }
                }
            }
        }
    }
}
-(void)setUpinit{
    for (int i = 0; i < _nodes.count; i++) {
        [((Node *)_nodes[i]) setUpinit];
    }
}
-(Node *)getBestNode{
    for (int i = 0; i< _nodes.count; i++) {
        Node * node = (Node *)_nodes[i];
        if (node.visited) {
            return node;
        }
    }
    return nil;
}
@end
