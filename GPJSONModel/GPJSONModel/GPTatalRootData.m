//
//  GPTatalRootData.m
//  GPJSONModel
//
//  Created by dandan on 17/2/7.
//  Copyright © 2017年 dandan. All rights reserved.
//

#import "GPTatalRootData.h"

@implementation GPTatalRootData


@end

@implementation GPTatalItem


@end

@implementation GPTatalData

+ (NSDictionary *)modelClassInArrayOrDictonary
{
    return @{@"floor" : [GPTatalFloor class]};
}
@end

@implementation GPTatalFloor
+ (NSDictionary *)modelClassInArrayOrDictonary
{
    return @{@"room" : [GPTatalRoom class]};
}
@end

@implementation GPTatalRoom
+ (NSDictionary *)modelClassInArrayOrDictonary
{
    return @{@"device" : [GPTatalControls class]};
}
@end

@implementation GPTatalControls
+ (NSDictionary *)modelClassInArrayOrDictonary
{
    return @{@"widget" : [GPTatalEvents class]};
}
@end

@implementation GPTatalEvents
+ (NSDictionary *)modelClassInArrayOrDictonary
{
    return @{
             @"items" : [GPTatalWidgetItems class],
             @"receive" : [GPTatalSendCommands class],
             @"send" : [GPTatalSendCommands class]
             };
}
@end

@implementation GPTatalCommands

@end

@implementation GPTatalSendCommands

@end

@implementation GPTatalWidgetItems

@end



