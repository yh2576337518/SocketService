//
//  ZJJSocketService.m
//  MyHomeKit
//
//  Created by 惠上科技 on 2018/6/11.
//  Copyright © 2018年 惠上科技. All rights reserved.
//

#import "ZJJSocketService.h"
@interface ZJJSocketService ()<GCDAsyncSocketDelegate>
@property(nonatomic,strong)GCDAsyncSocket *socket;
@property(nonatomic,strong)NSMutableArray *clientSockets;//保存客户端Socket
@end

@implementation ZJJSocketService
-(NSMutableArray *)clientSockets{
    if (_clientSockets == nil) {
        _clientSockets = [[NSMutableArray alloc] init];
    }
    return _clientSockets;
}

-(void)start{
    //1.创建socket对象
    GCDAsyncSocket *serviceScoket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    
    //2.绑定端口（9999）
    //端口任意，但遵循有效端口原则范围：0~65535 其中0~1024由系统使用或者保留端口，开发中建议使用1024以上的端口
    NSError *error = nil;
    [serviceScoket acceptOnPort:9999 error:&error];
    
    //3.开启服务（实质第二步绑定端口的同时默认开启服务）
    if (error == nil) {
        NSLog(@"开启成功");
    }else{
        NSLog(@"开启失败");
    }
    self.socket = serviceScoket;
}

#pragma mark --------GCDAsyncSocketDelegate
//连接到客户端socket
-(void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket{
    //socket 服务端的socket
    //newSocket 客户端连接的socket
    NSLog(@"%@--------%@",sock,newSocket);
    
    //1.保存连接的客户端socket(否则newSocket释放掉后连接会自动断开)
    [self.clientSockets addObject:newSocket];
    
    //连接成功服务端立即向客户端提供服务
    NSMutableString *serviceContent = [NSMutableString string];
    [serviceContent appendString:@"话费查询请按1\n"];
    [serviceContent appendString:@"话费充值请按2\n"];
    [serviceContent appendString:@"投诉建议请按3\n"];
    [serviceContent appendString:@"最新优惠请按4\n"];
    [serviceContent appendString:@"人工服务请按0\n"];
    [serviceContent appendString:@"无聊请按5\n"];
    [newSocket writeData:[serviceContent dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    
    //2.监听客户端有没有数据上传
    //-1代表不超时
    //tag标识作用
    [newSocket readDataWithTimeout:-1 tag:0];
}

//接收到客户端数据
-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    //1.接受到用户数据
    NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"服务端收到--->>%@",str);
    NSInteger code = [str integerValue];
    NSString *responseString =nil;
    switch (code) {
        case 1:
            responseString = @"您的账户余额为0，请尽快充值\n";
            break;
        case 2:
            responseString = @"系统忙，请稍后重试\n";
            break;
        case 3:
            responseString = @"系统忙，暂时不能接受投诉建议\n";
            break;
        case 4:
            responseString = @"请上官网查看更多优惠\n";
            break;
        case 5:
            responseString = @"无聊...\n";
            break;
        case 0:
            responseString = @"客服忙，谢谢!\n";
            break;
        default:
            break;
    }
    //处理请求返回数据
    [sock writeData:[responseString dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    
    [sock readDataWithTimeout:-1 tag:0];
}
@end
