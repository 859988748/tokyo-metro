//
//  ViewController.m
//  tokyo-metro
//
//  Created by llch on 15/10/12.
//  Copyright © 2015年 llch. All rights reserved.
//

#import "ViewController.h"
#import "Station.h"

@interface ViewController ()
{
    NSMutableDictionary * stationMap;
    NSMutableDictionary * tripMap;
    NSMutableArray * stations;
}
@end

@implementation ViewController

+(int)getTime:(NSString *)time{
    NSArray * item = [time componentsSeparatedByString:@":"];
    int t = (int)([item[0] integerValue] * 3600 + [item[1] integerValue] * 60 + [item[2] integerValue]);
    return t;
}
+(BOOL)addList:(NSMutableArray *)list Path:(NSArray *)paht{
    for (int i = 0; i <list.count; i ++) {
        if ([ViewController equalsNodes1:list[i] Nodes2:paht]) {
            return false;
        }
    }
    [list addObject:paht];
    return true;
}
+(BOOL)equalsNodes1:(NSArray *)p1 Nodes2:(NSArray *)p2{
    if (p1.count != p2.count) {
        return false;
    }
    for (int i= 0 ; i < p1.count; i ++) {
        if (p1[i] != p2[i]) {
            return false;
        }
    }
    return true;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //init data
    stationMap = [[NSMutableDictionary alloc] initWithCapacity:0];
    tripMap = [[NSMutableDictionary alloc] initWithCapacity:0];
    stations = [[NSMutableArray alloc]  initWithCapacity:0];
    
    
    //load data
    NSString *dataPath = [[NSBundle mainBundle] pathForResource:@"data" ofType:nil];
    NSLog(@"%@",dataPath);
    NSString * TripsPath = [dataPath stringByAppendingPathComponent:@"trips.txt"];
    NSString *StationPath = [dataPath stringByAppendingPathComponent:@"stops.txt"];
    NSString *StationNodePath = [dataPath stringByAppendingPathComponent:@"stop_times.txt"];
    NSError *error=nil;
    NSString *str=[NSString stringWithContentsOfFile:TripsPath encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"%@",error);
        exit(0);
    }else{
        NSArray * lines = [str componentsSeparatedByString:@"\n"];
        for (int i  = 1; i < (lines.count -1); i++) {
            NSArray * item = [[lines objectAtIndex:i] componentsSeparatedByString:@","];
            NSNumber * routeId = [NSNumber numberWithInteger:[[item objectAtIndex:0] integerValue]];
            NSNumber *tripId = [NSNumber numberWithInteger:[[item objectAtIndex:2] integerValue]];
            [tripMap setObject:routeId forKey:tripId];
        }
    }
    str=[NSString stringWithContentsOfFile:StationPath encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"%@",error);
        exit(0);
    }else{
        NSArray * lines = [str componentsSeparatedByString:@"\n"];
        for (int i  = 1; i < (lines.count -1); i++) {
            NSArray * item = [[lines objectAtIndex:i] componentsSeparatedByString:@","];
            NSString * stopId = [item objectAtIndex:0];
            NSString *stopName = [item objectAtIndex:2];
            Station * station = [[Station alloc] initWithSting:stopId Name:stopName];
            [stationMap setObject:station forKey:stopId];
        }
        stations = [NSMutableArray arrayWithArray:[[stationMap allValues] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            Station * s1 = obj1;
            Station * s2 = obj2;
            int id1 = [s1.stationId intValue];
            int id2 = [s2.stationId intValue];
            if (id1 > id2) {
                return NSOrderedDescending;
            }
            if (id1 < id2) {
                return NSOrderedAscending;
            }
            return NSOrderedSame;
        }]];
    }
    str=[NSString stringWithContentsOfFile:StationNodePath encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"%@",error);
        exit(0);
    }else{
        NSArray * stopTimes = [str componentsSeparatedByString:@"\n"];
        int lastTrip = 0;
        Node * lastNode = nil;
        for (int i  = 1; i < (stopTimes.count -1); i++) {
            NSArray * item = [[stopTimes objectAtIndex:i] componentsSeparatedByString:@","];
            int trip = [item[0] intValue];
            int route = [[tripMap objectForKey:[NSNumber numberWithInt:trip]] intValue];
            int arriveTime = [ViewController getTime:item[1]];
            NSString * stationId = item[3];
            if ((trip ==  lastTrip) && (lastNode.time == arriveTime)) {
                arriveTime += 1;
            }
            Node * node = [((Station *)[stationMap objectForKey:stationId]) setNodeArriveTime:arriveTime routId:route tripId:trip];
            if (trip == lastTrip) {
                [Node linkfrom:lastNode To:node];
            }
            lastTrip = trip;
            lastNode = node;
        }
        for (int i = 0; i < stations.count; i++) {
            [stations[i] selfLink];
        }
    }
}
-(NSArray *)getBestPathStartStr:(NSString *)start TimeStr:(NSString *)time RouteId:(int)routeId StopStr:(NSString *)stop MaxVaule:(int) max{
    Station * startS =nil;
    Station * stopS = nil;
    for (int i = 0 ; i < stations.count; i ++) {
        if ([((Station *)stations[i]).name isEqualToString:start]) {
            startS = stations[i];
        }
        if ([((Station *)stations[i]).name isEqualToString:stop]) {
            stopS = stations[i];
        }
        if (startS != nil && stopS != nil) {
            break;
        }
    }
    int t = [ViewController getTime:time];
    Node * startNode = nil;
    for (int i = 0 ; i < startS.getNodeCount; i++) {
        Node * n = [startS getNode:i];
        if (n.time >= t && n.routeId ==  routeId) {
            startNode = n;
            NSLog(@"filtered Start Node:%@",[startNode toString]);
            break;
        }
    }
    return [self getBestPathBeginNode:startNode EndStation:stopS Max:max];
}
-(NSArray *)getBestPathBeginNode:(Node *)begin EndStation:(Station *)end Max:(int) max{
    NSMutableArray * path = [[NSMutableArray alloc] initWithCapacity:0];
    for (Station * s in stations) {
        [s setUpinit];
    }
    [begin visit];
    Node * bestEnd = [end getBestNode];
    int nodeCount = 0;
    for (int j = 0;  j < [end getNodeCount]; j++) {
        Node * endNode = [end getNode:j];
        if (!endNode.visited) {
            continue;
        }
        nodeCount++;
        int count = 0;
        for (Station *s in stations) {
            for (int i = 0;  i < s.getNodeCount; i ++) {
                if ([s getNode:i].backVisited && [s getNode:i].visited) {
                    count++;
                }
            }
        }
        if (count < 500) {
            [ViewController addList:path Path:[begin getBestPath:bestEnd]];
            if (path.count > max) {
                break;
            }
        }
        [ViewController addList:path Path:[begin getForwardPath]];
        if (path.count > max) {
            break;
        }
        [ViewController addList:path Path:[bestEnd getBackwardPath]];
        if (path.count > max) {
            break;
        }
    }
    return path;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"可以开始计算路程" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alert show];
}
- (IBAction)searchPath:(id)sender {
    NSLog(@"begin Node:%@",[stations[0] getNode:30].station.name);
    NSLog(@"end station:%@",((Station *)stations[212]).name);
    NSTimeInterval beginT = [[NSDate date] timeIntervalSince1970];
//        NSArray * path = [self getBestPathBeginNode:[stations[0] getNode:30] EndStation:stations[212] Max:10];
    NSArray * path = [self getBestPathStartStr:@"代代木" TimeStr:@"9:4:0" RouteId:154 StopStr:@"日比谷" MaxVaule:10];
    //    NSLog(@"path: %@",path);
    NSTimeInterval endT = [[NSDate date] timeIntervalSince1970];
    NSLog(@"耗时：%f秒",(endT - beginT));
}
@end
