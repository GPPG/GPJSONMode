//
//  GPTatalRootData.h
//  GPJSONModel
//
//  Created by dandan on 17/2/7.
//  Copyright © 2017年 dandan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPJsonToModeTool.h"

@class GPTatalItem,GPTatalData;
@interface GPTatalRootData : NSObject

@property (nonatomic, strong) NSString * code;
@property (nonatomic, strong) GPTatalItem * items;
@property (nonatomic, strong) NSString * message;

@end

@interface GPTatalItem : NSObject

@property (nonatomic, strong) GPTatalData * ui;
@property (nonatomic, strong) NSString * mac;
@property (nonatomic, strong) NSString * name;
@property (nonatomic,copy) NSString *id;

@end


@interface GPTatalData : NSObject

@property (nonatomic, strong) NSArray * floor;

@end

@interface GPTatalFloor : NSObject

@property (nonatomic, strong) NSString * id;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSArray * room;
@property (nonatomic,copy) NSString *remark;

@end

@interface GPTatalRoom : NSObject

@property (nonatomic, strong) NSArray *device;
@property (nonatomic,copy) NSString *icon_id;
@property (nonatomic,copy) NSString *id;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *remark;

@end

@interface GPTatalControls : NSObject

@property (nonatomic,copy) NSArray *widget;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *id;
@property (nonatomic,copy) NSString *type;

@end

@interface GPTatalEvents : NSObject

@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) NSArray *receive;
@property (nonatomic,copy) NSString *type;
@property (nonatomic,copy) NSString *name;
@property (nonatomic, strong) NSArray *send;
@property (nonatomic,copy) NSString *maxvalue;
@property (nonatomic,copy) NSString *minvalue;

@end

@interface GPTatalCommands : NSObject

@property (nonatomic,copy) NSString *address;
@property (nonatomic,copy) NSString *value_type;
@property (nonatomic,copy) NSString *value;

@end

@interface GPTatalSendCommands : NSObject

@property (nonatomic,copy) NSString *address;
@property (nonatomic,copy) NSString *value_type;
@property (nonatomic,copy) NSString *value;

@end

@interface GPTatalWidgetItems : NSObject

@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *value;
@property (nonatomic,copy) NSString *value_type;

@end
