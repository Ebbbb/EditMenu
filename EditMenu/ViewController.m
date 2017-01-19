//
//  ViewController.m
//  EditMenu
//
//  Created by sobeycloud on 2017/1/4.
//  Copyright © 2017年 sobeycloud. All rights reserved.
//

#import "ViewController.h"
#import "SCCatalogMenuView.h"

@interface ViewController ()<SCCatalogMenuViewDelegate>
@property(nonatomic, strong)SCCatalogMenuView *catalogMenu;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.tag = 10;
    button.backgroundColor = [UIColor orangeColor];
    [button setTitle:@"编辑" forState:UIControlStateNormal];
    [button setTitle:@"完成" forState:UIControlStateSelected];
    [button addTarget:self action:@selector(buttonResponse:) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(20, 20, 60, 30);
    [self.view addSubview:button];
    
    _catalogMenu = [SCCatalogMenuView viewWithFrame:CGRectMake(0, 50, self.view.frame.size.width, 250)];
    _catalogMenu.delegate = self;
    _catalogMenu.currentArray = [NSMutableArray arrayWithObjects:@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1",nil];
    _catalogMenu.extraArray = [NSMutableArray arrayWithObjects:@"2",@"2",@"2",@"2",@"2",@"2",@"2",@"2",@"2",@"2",@"2",@"2",nil];
    [_catalogMenu reloadData];
    [self.view addSubview:_catalogMenu];
}

- (void)buttonResponse:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.catalogMenu.editing = sender.selected;
}

#pragma mark - SCCatalogMenuViewDelegate
- (void)editStateChanged:(BOOL)state {
    UIButton *button = (UIButton *)[self.view viewWithTag:10];
    button.selected = state;
}

- (void)didSelectedCurrentIndex:(NSInteger)index {
    NSLog(@"select %ld",index);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
