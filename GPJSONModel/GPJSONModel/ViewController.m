//
//  ViewController.m
//  GPJSONModel
//
//  Created by dandan on 17/1/27.
//  Copyright © 2017年 dandan. All rights reserved.
//

#import "ViewController.h"
#import "GPTatalRootData.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self dicToMode];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self dicToMode];
}

- (void)dicToMode
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"json.json" ofType:nil];
    //加载JSON文件
    NSData *data = [NSData dataWithContentsOfFile:path];
    GPTatalItem *item = [GPTatalItem GP_ModeWithJSON:data];
//    GPTatalItem *item =  rootData.items;
    GPTatalData *tData = item.ui;
    NSLog(@"%lu--%@",(unsigned long)tData.floor.count,item.name);
    for (GPTatalFloor *floorr in tData.floor) {
        NSLog(@"%@--%@--%@",floorr.name,floorr.remark,floorr.id);
    }
}
@end
