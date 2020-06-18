//
//  MainViewController.m
//  socket
//
//  Created by cherish on 2020/6/17.
//  Copyright © 2020 cherish. All rights reserved.
//

#import "ClientViewController.h"
#import <GCDAsyncSocket.h>
@interface ClientViewController ()<GCDAsyncSocketDelegate>

@property (nonatomic,assign) NSInteger count;
@property (nonatomic,strong) UITextField *IPAddr;
@property (nonatomic,strong) UITextField *portText;
@property (nonatomic,strong) GCDAsyncSocket *clientSocket;
@property (nonatomic,strong) UILabel *connectStatus;
@property (nonatomic,assign) BOOL connectFlag;
@property (nonatomic,strong) UITextField *messageTextView;
@property (nonatomic,strong) UITextView *receiveMessage;
@property (nonatomic,strong) NSTimer *connectTimer;

@end

@implementation ClientViewController

#pragma mark - ViewController Life
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Client socket(TCP/IP)";
    [self setUp];
}

#pragma mark - Private Methods
- (void)setUp
{
    //ip
    self.IPAddr = [[UITextField alloc]initWithFrame:CGRectMake(20, 100, self.view.frame.size.width-40, 40)];
    self.IPAddr.placeholder = @" input Server IP";
    self.IPAddr.layer.borderWidth = 0.5;
    self.IPAddr.layer.borderColor = [[UIColor blackColor] colorWithAlphaComponent:0.5].CGColor;
    self.IPAddr.layer.cornerRadius = 5.0f;
    self.IPAddr.keyboardType = UIKeyboardTypeDecimalPad;
    self.IPAddr.layer.masksToBounds = YES;
    self.IPAddr.font = [UIFont systemFontOfSize:15.0f];
    self.IPAddr.textColor = [UIColor blackColor];
    [self.view addSubview:self.IPAddr];
    
    //port
    self.portText = [[UITextField alloc]initWithFrame:CGRectMake(20, 160, self.view.frame.size.width-40, 40)];
    self.portText.placeholder = @" input port number";
    self.portText.textAlignment = NSTextAlignmentLeft;
    self.portText.layer.borderWidth = 0.5;
    self.portText.keyboardType = UIKeyboardTypeDecimalPad;
    self.portText.layer.borderColor = [[UIColor blackColor] colorWithAlphaComponent:0.5].CGColor;
    self.portText.layer.cornerRadius = 5.0f;
    self.portText.layer.masksToBounds = YES;
    self.portText.font = [UIFont systemFontOfSize:15.0f];
    self.portText.textColor = [UIColor blackColor];
    [self.view addSubview: self.portText];
    
    // start connect
    UIButton *connectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    connectBtn.frame = CGRectMake(self.view.frame.size.width-200, self.portText.frame.origin.y+60, 80, 30);
    [connectBtn setTitle:@"connect" forState:UIControlStateNormal];
    [connectBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [connectBtn setTitleColor:[[UIColor blueColor] colorWithAlphaComponent:0.1] forState:UIControlStateHighlighted];
    connectBtn.titleLabel.font = [UIFont systemFontOfSize:12.0f];
    connectBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    connectBtn.layer.borderColor = [UIColor blueColor].CGColor;
    connectBtn.layer.borderWidth = 0.5;
    connectBtn.layer.cornerRadius = 5.0f;
    connectBtn.layer.masksToBounds = YES;
    [connectBtn addTarget:self action:@selector(startConnectServer:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:connectBtn];
    
    // disconnect
    UIButton *disconnectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    disconnectBtn.frame = CGRectMake(self.view.frame.size.width-100, self.portText.frame.origin.y+60, 80, 30);
    [disconnectBtn setTitle:@"disconnect" forState:UIControlStateNormal];
    [disconnectBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [disconnectBtn setTitleColor:[[UIColor blueColor] colorWithAlphaComponent:0.1] forState:UIControlStateHighlighted];
    disconnectBtn.titleLabel.font = [UIFont systemFontOfSize:12.0f];
    disconnectBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    disconnectBtn.layer.borderColor = [UIColor blueColor].CGColor;
    disconnectBtn.layer.borderWidth = 0.5;
    disconnectBtn.layer.cornerRadius = 5.0f;
    disconnectBtn.layer.masksToBounds = YES;
    [disconnectBtn addTarget:self action:@selector(disConnectServer:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:disconnectBtn];
    
    // connect status
    self.connectStatus = [[UILabel alloc]initWithFrame:CGRectMake(20, self.portText.frame.origin.y+60, 80, 30)];
    self.connectStatus.text = @"unconnect";
    self.connectStatus.textColor = [UIColor grayColor];
    self.connectStatus.font = [UIFont systemFontOfSize:14.0f];
    self.connectStatus.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:self.connectStatus];
    
    // send message
    self.messageTextView = [[UITextField alloc]initWithFrame:CGRectMake(20, self.connectStatus.frame.origin.y+50,self.view.frame.size.width-150, 30)];
    self.messageTextView.textAlignment = NSTextAlignmentLeft;
    self.messageTextView.placeholder = @" input the content to be sent.";
    self.messageTextView.font = [UIFont systemFontOfSize:15.0f];
    self.messageTextView.layer.borderColor = [UIColor blueColor].CGColor;
    self.messageTextView.layer.borderWidth = 0.5;
    self.messageTextView.layer.cornerRadius = 5.0f;
    self.messageTextView.layer.masksToBounds = YES;
    [self.view addSubview:self.messageTextView];
    
    // send
    UIButton *postBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    postBtn.frame = CGRectMake(self.view.frame.size.width-100, self.connectStatus.frame.origin.y+50, 80, 30);
    [postBtn setTitle:@"send" forState:UIControlStateNormal];
    [postBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [postBtn setTitleColor:[[UIColor blueColor] colorWithAlphaComponent:0.1] forState:UIControlStateHighlighted];
    postBtn.titleLabel.font = [UIFont systemFontOfSize:12.0f];
    postBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    postBtn.layer.borderColor = [UIColor blueColor].CGColor;
    postBtn.layer.borderWidth = 0.5;
    postBtn.layer.cornerRadius = 5.0f;
    postBtn.layer.masksToBounds = YES;
    [postBtn addTarget:self action:@selector(postMessageToServer:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:postBtn];
    
    //receive message
    self.receiveMessage = [[UITextView alloc]initWithFrame:CGRectMake(20, postBtn.frame.origin.y+50, self.view.frame.size.width-40, 200)];
    self.receiveMessage.textAlignment = NSTextAlignmentLeft;
    self.receiveMessage.layer.cornerRadius = 5.0f;
    self.receiveMessage.layer.masksToBounds = YES;
    self.receiveMessage.font = [UIFont systemFontOfSize:14.0f];
    self.receiveMessage.textColor = [UIColor blackColor];
    self.receiveMessage.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3];
    self.receiveMessage.text = @"If a message is received, it will be displayed here \n";
    [self.view addSubview:self.receiveMessage];

}

- (void)addTimer
{
    self.connectTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(longConnectToServer:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.connectTimer forMode:NSRunLoopCommonModes];
}

#pragma mark - socket Delegate
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    self.connectStatus.text = @"connected";
    self.connectStatus.textColor = [UIColor greenColor];
    self.connectFlag = YES;
    [self addTimer];
    [self.clientSocket readDataWithTimeout:-1 tag:0];
    
}//connect status

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString *content = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    self.receiveMessage.text = [self.receiveMessage.text stringByAppendingString:[NSString stringWithFormat:@"\nA message was received that read: %@\n",content]];
    [self.clientSocket readDataWithTimeout:-1 tag:0];
    
}//receive message

#pragma mark - Action Methods
- (void)startConnectServer:(UIButton*)sender
{
    if (self.IPAddr.text.length>0 && self.portText.text.length>0) {
        self.connectStatus.text = @"connecting";
        NSError *error = nil;
        self.clientSocket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        self.connectFlag = [self.clientSocket connectToHost:self.IPAddr.text onPort:self.portText.text.integerValue error:&error];
        if (!self.connectFlag) {
            self.connectStatus.text = @"failure";
            self.connectStatus.textColor = [UIColor redColor];
        }else{
            self.connectStatus.text = @"connected";
            self.connectStatus.textColor = [UIColor greenColor];
            self.IPAddr.userInteractionEnabled = self.portText.userInteractionEnabled = NO;
        }
    }
}//connect server

- (void)postMessageToServer:(UIButton*)sender
{
    if (self.messageTextView.text.length>0) {
       NSData *postData = [self.messageTextView.text dataUsingEncoding:NSUTF8StringEncoding];
       [self.clientSocket writeData:postData withTimeout:-1 tag:0];
        self.messageTextView.text = @"";
        [self.view endEditing:YES];
    }
}//post message

- (void)disConnectServer:(UIButton*)sender
{
    if (self.connectFlag) {
        self.IPAddr.userInteractionEnabled = self.portText.userInteractionEnabled = YES;
        [self.view endEditing:YES];
        self.clientSocket = nil;
        self.clientSocket.delegate = nil;
        [self.connectTimer invalidate];
        self.connectTimer = nil;
        self.connectFlag = NO;
        self.connectStatus.text = @"unconnect";
        self.receiveMessage.text = @"If a message is received, it will be displayed here \n";
        self.count = 0;
        self.connectStatus.textColor = [UIColor lightGrayColor];
      
    }
}//disconnect

- (void)longConnectToServer:(NSTimer*)timer
{
    ++self.count;
    NSString *longConnect = [NSString stringWithFormat:@"heartbeat %ld",self.count];
    NSData  *data = [longConnect dataUsingEncoding:NSUTF8StringEncoding];
    [self.clientSocket writeData:data withTimeout:- 1 tag:0];
    
}//Send a heartbeat.

#pragma mark - OverRide Methods
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}


@end
