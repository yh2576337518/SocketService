//
//  main.m
//  SocketService
//
//  Created by 惠上科技 on 2018/6/12.
//  Copyright © 2018年 惠上科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZJJSocketService.h"
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        
        //创建服务对象
        ZJJSocketService *socketSerview = [[ZJJSocketService alloc]init];
        //开始服务
        [socketSerview start];
        //循环运行
        [[NSRunLoop mainRunLoop]run];//目的让服务器不停止
    }
    return 0;
}
