//
//  Node.h
//  tokyo-metro
//
//  Created by llch on 15/10/12.
//  Copyright © 2015年 llch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Station.h"
@class Station;

@interface Node : NSObject

@property(strong) Station * station;
@property(strong) NSMutableArray * next;
@property(strong) NSMutableArray * prev;
@property int time;
@property int routeId;
@property BOOL visited;
@property BOOL backVisited;
@property Node * prevNode;
@property int tripId;
@property int value;

+(void)linkfrom:(Node *)from To:(Node *)to;
-(instancetype) initWithStationg:(Station *)station Time:(int) time routeId:(int) routeId tripId:(int) tripId;
-(void)setUpinit;
-(void)backVisit;
-(void)visit;
-(NSString *)getTimeStr;
-(NSArray *)getForwardPath;
-(NSArray *)getBackwardPath;
-(NSArray *)getBestPath:(Node *)end;
-(NSString *)toString;
@end
