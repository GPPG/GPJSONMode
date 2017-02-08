//
//  GPClassInfo.m
//  GPJSONModel
//
//  Created by dandan on 17/2/4.
//  Copyright © 2017年 dandan. All rights reserved.
//

#import "GPClassInfo.h"

static NSCache *s_classInfoCache;

@implementation GPClassInfo

- (instancetype)initWithClass:(Class)cls
{
    if (!cls) {
        return nil;
    }
    // 取缓存
    id cacheInfo = [self objectOnCacheForClass:cls];
    if (cacheInfo) {
        return cacheInfo;
    }
    
    if (self = [super init]) {
        _cls = cls;
        unsigned int propertyCount = 0;
        // 获取属性 list
        objc_property_t *properties = class_copyPropertyList(_cls, &propertyCount);

        if (properties) {
            NSMutableDictionary *propertyInfo = [NSMutableDictionary dictionaryWithCapacity:propertyCount];
            for (unsigned int i = 0; i < propertyCount; i ++) {
                GPPropertyInfo *info = [[GPPropertyInfo alloc]initWithProperty:properties[i]];
                if (info.propertyName) {
                    propertyInfo[info.propertyName] = info;
                }
            }
            free(properties);
            _propertyInfo = [propertyInfo copy];
        }
    }
    [self setObjectToCacheForClass:cls];
    return self;
}
// 取缓存
- (id)objectOnCacheForClass:(Class)class
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_classInfoCache = [[NSCache alloc]init];
        s_classInfoCache.totalCostLimit = 0.5*1024*1024;
        s_classInfoCache.countLimit = 50;
    });
    id cacheInfo = [s_classInfoCache objectForKey:class];
    return cacheInfo;
}
// 设置缓存
- (void)setObjectToCacheForClass:(Class)class
{
    [s_classInfoCache setObject:self forKey:class];
}
@end
