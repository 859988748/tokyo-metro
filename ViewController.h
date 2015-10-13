//
//  ViewController.h
//  tokyo-metro
//
//  Created by llch on 15/10/12.
//  Copyright © 2015年 llch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Node.h"

@interface ViewController : UIViewController

+(int)getTime:(NSString *)time;
+(BOOL)addList:(NSMutableArray *)list Path:(NSArray *)path;
+(BOOL)equalsNodes1:(NSArray *)p1 Nodes2:(NSArray *)p2;
@end

