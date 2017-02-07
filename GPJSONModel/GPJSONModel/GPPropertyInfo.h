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
@property (nonatomic, strong) NSString *propertyName;
// 属性 class 的类型
@property (nonatomic, strong) Class typeClass;
// 是否自定义对象类型
@property (nonatomic,assign) BOOL isCustomFondation;
// 属性 setter 方法
@property (nonatomic,assign) SEL setter;
// 属性 getter 方法
@property (nonatomic,assign) SEL getter;

- (instancetype)initWithProperty:(objc_property_t)property;
// 是否是Foundation对象类型
+ (BOOL)isClassFromFoundation:(Class)cls;

@end
