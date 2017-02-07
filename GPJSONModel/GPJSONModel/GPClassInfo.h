//
//  GPClassInfo.h
//  GPJSONModel
//
//  Created by dandan on 17/2/4.
//  Copyright © 2017年 dandan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPPropertyInfo.h"

@interface GPClassInfo : NSObject

@property (nonatomic, strong,readonly) NSDictionary *propertyInfo;
@property (nonatomic,assign,readonly) Class cls;
- (instancetype)initWithClass:(Class)cls;

@end
