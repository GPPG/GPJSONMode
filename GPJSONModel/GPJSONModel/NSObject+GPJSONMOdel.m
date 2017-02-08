//
//  NSObject+GPJSONMOdel.m
//  GPJSONModel
//
//  Created by dandan on 17/1/27.
//  Copyright © 2017年 dandan. All rights reserved.
//

#import "NSObject+GPJSONMOdel.h"
#import <objc/message.h>

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
            // value 是数组
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
            // value 是字典
        else if ([value isKindOfClass:[NSDictionary class]]){
            // 判断是否为自定义模型
            if (propertyInfo.isCustomFondation) {
                // 字典对应模型
                value = [propertyInfo.typeClass GP_ModeWithDictonary:value];
            }
            else if ([propertyInfo.typeClass isSubclassOfClass:[NSDictionary class]]){
                // 属性是字典类型
                Class class = nil;
                if (modelClassDic) {
                    class = [modelClassDic objectForKey:key];
                }
                if (class) {
                    value = [(NSDictionary *)value GP_ModelDictionaryWithClass:class];
                }else if ([self respondsToSelector:@selector(shouldCustomUnkownValueWithKey:)] && [self shouldCustomUnkownValueWithKey:key] && [self respondsToSelector:@selector(customValueWithKey:unkownValueDic:)]) {
                    // 自定义处理未知value
                    value = [self customValueWithKey:key unkownValueDic:value];
                }
            }else {
                // 属性 不是 字典类型 返回数据有误
                value = nil;
            }
        }
            if ([value isEqual:[NSNull null]]) {
                // 去除 null
                value = nil;
            }
            if (propertyInfo.typeClass) {
                if ([propertyInfo.typeClass isSubclassOfClass:[NSString class]] && [value isKindOfClass:[NSNumber class]]) {
                    value = [(NSNumber *)value stringValue];
                    
                }
                else if (propertyInfo.typeClass == [NSValue class] || propertyInfo.typeClass == [NSDate class]) {
                    value = nil;
                }
                // 调用 setter 方法,设置值
                [self setPropertyWithModel:self value:value setter:propertyInfo.setter];
            }
            else if (value){
                // 基本类型
                if ([value isKindOfClass:[NSString class]]) {
                    static NSNumberFormatter *s_numberFormatter;
                    static dispatch_once_t onceToken;
                    dispatch_once(&onceToken, ^{
                        // NSString 转 NSNumber Formatter
                        s_numberFormatter = [[NSNumberFormatter alloc]init];
                    });
                    // string 转 number
                    value = [s_numberFormatter numberFromString:value];
                }
                // kvc 设置基本类型的值
                [self setValue:value forKey:key];
            }
        }
    }];
}

#pragma mark - set,get 方法
// set
- (void)setPropertyWithModel:(id)model value:(id)value setter:(SEL)setter
{
    if (!setter) {
        return;
    }
    ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, setter, value);
}
// get
- (id)propertyValueWithModel:(id)model getter:(SEL)getter
{
    if (!getter) {
        return nil;
    }
    return ((id (*)(id, SEL))(void *) objc_msgSend)((id)model,getter);
}

#pragma mark - 模型转 json
- (NSDictionary *)GP_ModelToDictonary
{
    if ([self isKindOfClass:[NSArray class]]) {
        return nil;
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
    
    // 获取 当前类信息
    GPClassInfo *classInfo = [[GPClassInfo alloc]initWithClass:object_getClass(self)];
    // 字典
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:classInfo.propertyInfo.count];
    
    [classInfo.propertyInfo enumerateKeysAndObjectsUsingBlock:^(NSString *key, GPPropertyInfo *propertyInfo, BOOL *stop) {
        
        BOOL isIgnoreProperty = NO;
        id value = nil;
        
        if (ignoreProperties) {
            // 是否忽略这个属性
            isIgnoreProperty = [ignoreProperties containsObject:key];
        }
        
        if (!isIgnoreProperty) {
            
            if (propertyInfo.typeClass) {
                value = [self propertyValueWithModel:self getter:propertyInfo.getter];
            }
            else{
                value = [self valueForKey:key];
            }
        }
        if (!isIgnoreProperty && value) {
            
            // 如果有值
            if ([value isKindOfClass:[NSArray class]]) {
                // 如果值是数组（可能包含模型） 调用model数组转dic数组方法
                value = [(NSArray *)value GP_ModelArrayToDicArray];
            }else if ([value isKindOfClass:[NSDictionary class]]) {
                // 如果值是字典（可能包含模型） 调用字典 model转dic方法
                value = [(NSDictionary *)value GP_ModelDictionaryToDictionary];
            }else if (propertyInfo.typeClass && propertyInfo.isCustomFondation) {
                value = [value GP_ModelToDictonary];
            }
            if (value) {
                NSString *maperKey = nil;
                if (propertyMapper) {
                    //映射key
                    maperKey = [propertyMapper objectForKey:key];
                }
                // 添加到字典
                dic[maperKey ? maperKey : key] = value;
            }
        }
    }];
    return [dic copy];
}
// model to json
- (id)GP_ModelToJSONObject
{
    if ([self isKindOfClass:[NSArray class]]) {
        // 如果是数组
        return [(NSArray *)self GP_ModelArrayToDicArray];
    }
    
    return [self GP_ModelToDictonary];
}

- (NSData *)GP_ModelToJSONData
{
    id jsonObject = [self GP_ModelToJSONObject];
    if (!jsonObject) return nil;
    return [NSJSONSerialization dataWithJSONObject:jsonObject options:0 error:NULL];
}

- (NSString *)GP_ModelToJSONString
{
    NSData *jsonData = [self GP_ModelToJSONData];
    if (jsonData.length == 0) return nil;
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

// dic array to model array
+ (NSArray *)GP_ModelArrayWithDictionaryArray:(NSArray *)dicArray
{
    return [dicArray GP_ModelArrayWithClass:[self class]];
}
// model array to dic array
+ (NSArray *)GP_DictionaryArrayWithModelArray:(NSArray *)dicArray
{
    return [dicArray GP_ModelArrayToDicArray];
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
// 模型数组转数组
- (NSArray *)GP_ModelArrayToDicArray
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.count];
    
    for (id obj in self) {
    
        if (![GPPropertyInfo isClassFromFoundation:[obj class]]) {
            NSDictionary *dic = [obj GP_ModelToDictonary];
            if (dic) {
                [array addObject:dic];
            }
        }
        else{
            [array addObject:obj];
        }
    }
    return [array copy];
}
@end

@implementation NSDictionary (GPJSONMOdel)
// 字典转模型字典
- (NSDictionary *)GP_ModelDictionaryWithClass:(Class)cls
{
    
    if (!cls) {
        return self;
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    // 遍历字典
    [self enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL * _Nonnull stop) {
        if ([key isKindOfClass:[NSString class]]) {
            NSObject *value = [cls GP_ModeWithDictonary:obj];
            if (value) {
                dic[key] = value;
            }
        }
    }];
    return [dic copy];
}
// 模型字典转字典
- (NSDictionary *)GP_ModelDictionaryToDictionary
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:self.count];
    // 遍历字典
    [self enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        
        if (![GPPropertyInfo isClassFromFoundation:[obj class]]) {
            // obj 是 模型 则 model to dic
            NSDictionary *objDic = [obj GP_ModelToDictonary];
            if (objDic) {
                dic[key] = objDic;
            }
        }
        else{
            dic[key] = obj;
        }
    }];
    return [dic copy];
}
@end
