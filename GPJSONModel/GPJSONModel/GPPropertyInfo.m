//
//  GPPropertyInfo.m
//  GPJSONModel
//
//  Created by dandan on 17/2/4.
//  Copyright © 2017年 dandan. All rights reserved.
//

#import "GPPropertyInfo.h"

@implementation GPPropertyInfo

- (instancetype)initWithProperty:(objc_property_t)property
{
    if (!property) {
        return nil;
    }
    
    if (self = [super init]) {
        // 获取属性名
        const char *cPropertyName = property_getName(property);
        if (cPropertyName) {
            _propertyName = [NSString stringWithUTF8String:cPropertyName];
        }
        
        BOOL readOnlyProperty = NO;
        unsigned int attrCount;
        // 获取属性列表
        objc_property_attribute_t *attrs = property_copyAttributeList(property, &attrCount);
        for (unsigned int idx = 0; idx < attrCount; ++idx) {
            switch (attrs[idx].name[0]) {
                case 'T':
                    if (attrs[idx].name[0] == 'T') {
                        size_t len = strlen(attrs[idx].value);
                        if (len>3) {
                            // 创建数组
                            char name[len - 2];
                            name[len - 3] = '\0';
                            // 执行拷贝操作,获得类型字符串
                            memcpy(name, attrs[idx].value + 2, len - 3);
                            _typeClass = objc_getClass(name);
                        }
                    }
                    break;
                case 'R':
                    readOnlyProperty = YES;
                    break;
                case 'G':
                    if (attrs[idx].value) {
                        _getter = NSSelectorFromString([NSString stringWithUTF8String:attrs[idx].value]);
                    }
                    break;
                case 'S':
                    if (attrs[idx].value) {
                        _setter = NSSelectorFromString([NSString stringWithUTF8String:attrs[idx].value]);
                    }
                    break;

                default:
                    break;
            }
        }
        
        if (attrs) {
            free(attrs);
        }
        
        if (_typeClass && _propertyName.length > 0) {
            
            if (!_getter) {
                _getter = NSSelectorFromString(_propertyName);
            }
            
            if (!_setter && !readOnlyProperty) {
                _setter = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:", [_propertyName substringToIndex:1].uppercaseString, [_propertyName substringFromIndex:1]]);
            }
        }
    }
    return self;
}
+ (BOOL)isClassFromFoundation:(Class)cls
{
    if (cls == [NSString class] || cls == [NSObject class]) {
        return YES;
    }
    static NSArray *s_foundations;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_foundations = @[[NSURL class],
                          [NSDate class],
                          [NSValue class],
                          [NSData class],
                          [NSError class],
                          [NSArray class],
                          [NSDictionary class],
                          [NSString class],
                          [NSAttributedString class]];
    });
    BOOL result = NO;
    for (Class foundationClass in s_foundations) {
        if ([cls isSubclassOfClass:foundationClass]) {
            result = YES;
            break;
        }
    }
    return result;
}
@end
