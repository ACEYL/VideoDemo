//
//  ViewController.m
//  videoDemo
//
//  Created by Yuan on 16/2/19.
//  Copyright © 2016年 Ace. All rights reserved.
//

#import "ViewController.h"
#import "MakeVideoViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(100, 144, 50, 30)];
    [button setTitle:@"按钮" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
}

-(void)buttonPressed
{
    MakeVideoViewController *makeVideo = [[MakeVideoViewController alloc]init];
    UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:makeVideo];
    
    
    [self presentViewController:navi animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
