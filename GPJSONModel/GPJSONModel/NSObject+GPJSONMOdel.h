//
//  NSObject+GPJSONMOdel.h
//  GPJSONModel
//
//  Created by dandan on 17/1/27.
//  Copyright © 2017年 dandan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (GPJSONMOdel)
// json转模型
+(instancetype)GP_ModeWithJSON:(id)json;

@end

@interface NSArray (GPJSONMOdel)


@end

@interface NSDictionary (GPJSONMOdel)

@end
