//
//  ViewController.m
//  Socket
//
//  Created by GM on 2018/3/28.
//  Copyright © 2018年 GM. All rights reserved.
//

#import "ViewController.h"
#import "GCDAsyncSocket.h"
@interface ViewController ()<GCDAsyncSocketDelegate,UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) GCDAsyncSocket *clientSocket;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *chatMsgs;//聊天消息数组
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate=self;
    self.tableView.dataSource =self ;
    //self.view.backgroundColor = [UIColor redColor];
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 400, 300, 60)];
    btn.backgroundColor = [UIColor orangeColor];
    [btn setTitle:@"长链接发送数据" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(clickBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    self.clientSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    NSError *error = nil;
    [self.clientSocket connectToHost:@"127.0.0.1" onPort:12345 error:&error];
    if (error) {
        NSLog(@"error == %@",error);
    }
}
-(NSMutableArray *)chatMsgs{
    
    if(!_chatMsgs) {
        
        _chatMsgs =[NSMutableArray array];
        
    }
    
    return _chatMsgs;
}
- (void)clickBtn{
    NSString *msg = @"发送数据: 你好\r\n";
    NSDictionary *dict = @{
                           @"head" : @"phoneNum",
                           @"body" : @(13133334444),
                           @"end" : @(11)};

  [self reloadDataWithText:msg];
  NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding];
    // NSData * data =  [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    // withTimeout -1 : 无穷大,一直等
    // tag : 消息标记
    [self.clientSocket writeData:data withTimeout:-1 tag:0];
}
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"链接成功");
    NSLog(@"服务器IP: -%@端口: %d",host,port);
}
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"发送数据 tag = %zi",tag);
    [sock readDataWithTimeout:-1 tag:tag];
}
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"读取数据 data = %@ tag = %zi",str,tag);
    // 读取到服务端数据值后,能再次读取
   
         //从服务器接收到的数据

    

    
    [self reloadDataWithText:str];
    [sock readDataWithTimeout:- 1 tag:tag];
}



- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"断开连接");
    self.clientSocket.delegate = nil;
    self.clientSocket = nil;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)reloadDataWithText:(NSString *)text{
    
         [self.chatMsgs addObject:text];
    
         [self.tableView reloadData];
    
         //数据多，应该往上滚动
    
         NSIndexPath *lastPath = [NSIndexPath indexPathForRow:self.chatMsgs.count -1 inSection:0];
    
         [self.tableView scrollToRowAtIndexPath:lastPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
     }

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
         return self.chatMsgs.count;
    
     }

 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath

 {
    
         static NSString *ID =@"Cell";
    
         UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:ID];
     if (cell==nil){
         cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
     }
    
     cell.textLabel.text =self.chatMsgs[indexPath.row];
    
         return cell;
    
    }



-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.clientSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    NSError *error = nil;
    [self.clientSocket connectToHost:@"127.0.0.1" onPort:12345 error:&error];
    if (error) {
        NSLog(@"error == %@",error);
    }
}
@end
