//
//  NSObject+GPJSONMOdel.m
//  GPJSONModel
//
//  Created by dandan on 17/1/27.
//  Copyright © 2017年 dandan. All rights reserved.
//

#import "NSObject+GPJSONMOdel.h"

@implementation NSObject (GPJSONMOdel)
#pragma mark - json转模型
+ (instancetype)GP_ModeWithJSON:(id)json
{
    if (!json) {
        return nil;
    }
    
    NSDictionary *dic = nil;
    NSData *jsonData = nil;
    
    if ([json isKindOfClass:[NSDictionary class]]) {
        dic = json;
    }
    else if ([json isKindOfClass:[NSString class]]){
        jsonData = [(NSString *)json dataUsingEncoding: NSUTF8StringEncoding];
    }
    else if ([json isKindOfClass:[NSData class]]){
        jsonData = json;
    }
    
    if (jsonData) {
        dic = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
        if (![dic isKindOfClass:[NSDictionary class]]) {
            dic = nil;
        }
    }
    return [self GP_ModeWithDictonary:dic];
}
// 字典转模型
+ (instancetype)GP_ModeWithDictonary:(NSDictionary *)dic
{
    if (!dic) {
        return nil;
    }
    NSObject *model = [[[self class]alloc] init];
    
    [model GP_SetModelWithDictonary:dic];
    
    return model;
    
}
// 字典转模型
- (void)GP_SetModelWithDictonary:(NSDictionary *)dic
{
    
    if (!dic || ![dic isKindOfClass:[NSDictionary class]] || dic.count == 0) {
        return;
    }
    // 获取当前类的信息
    GPClassInfo *classInfo = [[GPClassInfo alloc]initWithClass:object_getClass(self)];
    // 二级转换
    NSDictionary *modelClassDic = nil;
    if ([[self class] respondsToSelector:@selector(modelClassInArrayOrDictonary)]) {
        modelClassDic = [[self class] modelClassInArrayOrDictonary];
    }
    // 属性 映射
    NSDictionary *propertyMapper = nil;
    if ([[self class] respondsToSelector:@selector(modelPropertyMapper)]) {
        propertyMapper = [[self class] modelPropertyMapper];
    }
    
    // 忽略 某些属性
    NSArray *ignoreProperties = nil;
    if ([[self class] respondsToSelector:@selector(ignoreModelProperties)]) {
        ignoreProperties = [[self class] ignoreModelProperties];
    }
    // 遍历当前类的所有属性
    [classInfo.propertyInfo enumerateKeysAndObjectsUsingBlock:^(NSString *key, GPPropertyInfo *propertyInfo, BOOL * _Nonnull stop) {
        
        BOOL isIgnoreProperty = NO;
        id value = nil;
        
        if (ignoreProperties) {
            // 是否忽略这个属性
            isIgnoreProperty = [ignoreProperties containsObject:key];
        }
        // 映射
        if (!isIgnoreProperty) {
            NSString *maperKey = nil;
            if (propertyMapper) {
                maperKey = [propertyMapper objectForKey:key];
            }
            // 根据属性名获得字典中的 Value
            value = [dic objectForKey:maperKey ? maperKey : key];
        }
        // 转换模型
        if (!isIgnoreProperty && value) {
            // value 有值
            if ([value isKindOfClass:[NSArray class]]) {
                // 校验 property 是否为数组类型
                if ([propertyInfo.typeClass isSubclassOfClass:[NSArray class]]) {
                    Class class = nil;
                    if (modelClassDic) {
                        // 数组中包含的模型
                        class = [modelClassDic objectForKey:key];
                    }
                    if (class) {
                        // 包含调用数组的转模型方法
                        value = [(NSArray *)value GP_ModelArrayWithClass:class];
                    }
                    else if ([self respondsToSelector:@selector(shouldCustomUnkownValueWithKey:)] && [self shouldCustomUnkownValueWithKey:key] && [self respondsToSelector:@selector(customValueWithKey:unkownValueArray:)]){
                        // 自定义处理未知 value
                        value = [self customValueWithKey:key unkownValueArray:value];
                    }
                }else{
                    // 返回数据有误
                    value = nil;
                }
            }
            
        else if ([value isKindOfClass:[NSDictionary class]]){
                
                
                
                
        }
            
            
            
            
            
            
        }
    }];
}


@end


@implementation NSArray (GPJSONMOdel)
// 数组转模型数组
- (NSArray *)GP_ModelArrayWithClass:(Class)cls
{
    if (!cls) {
        return self;
    }
    
    NSMutableArray *modelArray = [NSMutableArray array];
    
    for (id value in self) {
        
        if ([value isKindOfClass:[NSDictionary class]]) {
            NSObject *obj = [cls GP_ModeWithDictonary:value];
            if (obj) {
                [modelArray addObject:obj];
            }
        }
        else if ([value isKindOfClass:[NSString class]]){
            [modelArray addObject:value];
        }
    }
    return modelArray;
}
@end



@implementation NSDictionary (GPJSONMOdel)

// 字典转模型字典
- (NSDictionary *)GP_ModelDictionaryWithClass:(Class)cls
{
    
    
    
}


@end


















