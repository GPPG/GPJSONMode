//
//  NSObject+GPJSONMOdel.h
//  GPJSONModel
//
//  Created by dandan on 17/1/27.
//  Copyright © 2017年 dandan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPClassInfo.h"

@protocol  GPJSONMOdel <NSObject>

@optional
// 数组[value,value] 或 字典{key: value,key: value} value模型映射类型
+ (NSDictionary *)modelClassInArrayOrDictonary;

// 属性名 - key 映射
+ (NSDictionary *)modelPropertyMapper;

// 忽略某些属性
+ (NSArray *)ignoreModelProperties;

// 是否自定义未识别（不能处理的）value
- (BOOL)shouldCustomUnkownValueWithKey:(NSString *)key;

// 处理未识别（不能处理的）字典value 返回自定义的value
- (id)customValueWithKey:(NSString *)key unkownValueDic:(NSDictionary *)unkownValueDic;

// 处理未识别（不能处理的）数组value 返回自定义的value
- (id)customValueWithKey:(NSString *)key unkownValueArray:(NSArray *)unkownValueArray;

@end

@interface NSObject (GPJSONMOdel)<GPJSONMOdel>
// json转模型
+ (instancetype)GP_ModeWithJSON:(id)json;
+ (instancetype)GP_ModeWithDictonary:(NSDictionary *)dic;
- (void)GP_SetModelWithDictonary:(NSDictionary *)dic;

// 模型转 json
- (id)GP_ModelToJSONObject;
- (NSData *)GP_ModelToJSONData;
- (NSString *)GP_ModelToJSONString;
- (NSDictionary *)GP_ModelToDictonary;

// dic array to model array
+ (NSArray *)GP_ModelArrayWithDictionaryArray:(NSArray *)dicArray;
// model array to dic array
+ (NSArray *)GP_DictionaryArrayWithModelArray:(NSArray *)dicArray;
@end

@interface NSArray (GPJSONMOdel)
// 数组转模型数组
- (NSArray *)GP_ModelArrayWithClass:(Class)cls;
// 模型数组转为数组
- (NSArray *)GP_ModelArrayToDicArray;
@end

@interface NSDictionary (GPJSONMOdel)
// 字典转模型
- (NSDictionary *)GP_ModelDictionaryWithClass:(Class)cls;
// 模型转字典
- (NSDictionary *)GP_ModelDictionaryToDictionary;
@end
