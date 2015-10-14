 //
//  Node.m
//  tokyo-metro
//
//  Created by llch on 15/10/12.
//  Copyright © 2015年 llch. All rights reserved.
//

#import "Node.h"

@interface Node ()

@end

@implementation Node

+(void)linkfrom:(Node *)from To:(Node *)to{
    [from.next addObject:to];
    [to.prev addObject:from];
}

-(instancetype) initWithStationg:(Station *)station Time:(int) time routeId:(int) routeId tripId:(int) tripId{
    self = [super init];
    if (self) {
        _station =  station;
        _time = time;
        _routeId = routeId;
        _tripId = tripId;
        _next = [[NSMutableArray alloc] initWithCapacity:0];
        _prev = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return  self;
}

-(void)setUpinit{
    _visited = false;
    _backVisited = false;
    _value = INT_MAX;
}
-(void)backVisit{
    if (_backVisited) {
        return;
    }
    _backVisited = true;
    for (int i = 0; i<_prev.count; i++) {
        [[_prev objectAtIndex:i] backVisit];
    }
}
-(void)visit{
    if (_visited) {
        return;
    }
    _visited = true;
    for (int i = 0 ; i < _next.count; i ++) {
        [[_next objectAtIndex:i] visit];
    }
}

-(NSString *)getTimeStr{
    int time = _time;
    NSString * s = @"";
    s = [s stringByAppendingString:[NSString stringWithFormat:@"%d",time%60]];
    time = time/60;
    s =[NSString stringWithFormat:@"%d:%@",time%60,s];
    time = time/60;
    s = [NSString stringWithFormat:@"%d:%@",time%60,s];
    return s;
}
-(NSArray *)getForwardPath{
    NSMutableArray * list = [NSMutableArray arrayWithCapacity:0];
    Node * node = self;
    BOOL trans = true;
    while (true) {
        [list addObject:node];
        Node * next = [node findNext:trans];
        if (next == nil) {
            break;
        }
        if (trans && next.station == node.station) {
            [list removeLastObject];
        }
        trans = next.tripId != node.tripId;
        node = next;
    }
    return [self filter:list];
}
-(NSArray *)getBackwardPath{
    NSMutableArray * list = [NSMutableArray arrayWithCapacity:0];
    Node * node = self;
    BOOL trans = true;
    while (true) {
        [list insertObject:node atIndex:0];
        Node * next = [node findPrev:trans];
        if (next == nil) {
            break;
        }
        trans = (next.tripId != node.tripId);
        node = next;
    }
    return [self filter:list];
}
-(NSMutableArray *)filter:(NSMutableArray *)nodes{
    NSMutableArray * list = [NSMutableArray arrayWithCapacity:0];
    BOOL trans = true;
    for (int i = 0; i < nodes.count; i++) {
        [list addObject:[nodes objectAtIndex:i]];
        if ((i+1) >= nodes.count) {
            if (trans) {
                [list removeLastObject];
            }
            break;
        }
        if (trans && ((Node *)nodes[i + 1]).tripId != ((Node *)nodes[i]).tripId) {
            [list removeLastObject];
        }
        trans = (((Node *)nodes[i + 1]).tripId != ((Node *)nodes[i]).tripId);
    }
    return list;
}
-(Node *)findNext:(BOOL) trans{
    Node * best = nil;
    for (int i = 0; i < _next.count; i ++) {
        Node *p = _next[i];
        if (p.backVisited) {
            if ([self getPriorityForNode:best Trans:trans] < [self getPriorityForNode:p Trans:trans]) {
                best = p;
            }
        }
    }
    return best;
}
-(Node *)findPrev:(BOOL) trans{
    Node * best = nil;
    for (int i = 0; i < _prev.count; i++) {
        Node * p = _prev[i];
        if (p.visited) {
            if ([self getPriorityForNode:best Trans:trans] < [self getPriorityForNode:p Trans:trans]) {
                best = p;
            }
        }
    }
    return best;
}
-(int)getPriorityForNode:(Node *)node Trans:(BOOL)trans{
    if (node == nil) {
        return 0;
    }
    if (trans) {
        if (node.station != self.station) {
            return 1;
        }
        if (node.routeId != self.routeId) {
            return 2;
        }
        return 3;
    }else{
        if (node.tripId == self.tripId) {
            return 3;
        }
        if (node.routeId == self.routeId) {
            return 2;
        }
        return 1;
    }
}
-(NSArray *)getBestPath:(Node *)end{
    NSMutableArray * list = [NSMutableArray arrayWithCapacity:0];
    [self updateTransValuePrevNode:nil Node:self Value:0];
    [self updateValuePrevNode:nil Node:self Value:0];
    Node * node = end;
    while (true) {
        [list insertObject:node atIndex:0];
        node = node.prevNode;
        if (node == nil) {
            return [self filter:list];
        }
    }
}
-(void)updateValuePrevNode:(Node *)prevNode Node:(Node *)node Value:(int)value{
    if (node.value > value) {
        node.prevNode = prevNode;
        node.value = value;
        for (Node * child in node.next) {
            if (child.backVisited && child.visited) {
                if (child.station == node.station) {
                    [self updateTransValuePrevNode:node Node:child Value:value+1];
                    [self updateValuePrevNode:node Node:child Value:value+1];
                }else{
                    [self updateValuePrevNode:node Node:child Value:value];
                }
            }
        }
    }
}
-(void)updateTransValuePrevNode:(Node *)prevNode Node:(Node *)node Value:(int)value{
    for (Node * child in node.next) {
        if (child.backVisited && child.visited && child.station == node.station) {
            [self updateTransValuePrevNode:prevNode Node:child Value:value];
            [self updateValuePrevNode:prevNode Node:child Value:value];
        }
    }
}
-(NSString *)toString{
    return [NSString stringWithFormat:@"%@,%@,%@,%d号线（班次%d)",_station.stationId,_station.name,[self getTimeStr],_routeId,_tripId];
}
- (NSString *)description{
    return [self toString];
}
@end
