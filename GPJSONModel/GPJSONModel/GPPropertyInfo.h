//
//  GPPropertyInfo.h
//  GPJSONModel
//
//  Created by dandan on 17/2/4.
//  Copyright © 2017年 dandan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface GPPropertyInfo : NSObject
// 属性名
@property (nonatomic, strong,readonly) NSString *propertyName;
// 属性 class 的类型
@property (nonatomic, strong,readonly) Class typeClass;
// 是否自定义对象类型
@property (nonatomic,assign,readonly) BOOL isCustomFondation;
// 属性 setter 方法
@property (nonatomic,assign,readonly) SEL setter;
// 属性 getter 方法
@property (nonatomic,assign,readonly) SEL getter;

- (instancetype)initWithProperty:(objc_property_t)property;
// 是否是Foundation对象类型
+ (BOOL)isClassFromFoundation:(Class)cls;

@end
