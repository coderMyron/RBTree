//
//  ViewController.m
//  RBTree
//
//  Created by Myron on 2019/8/6.
//  Copyright © 2019 Myron. All rights reserved.
//

#import "ViewController.h"
#import "RBTree.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    RBTree * rbTree = [RBTree sharedRBTree];
    [rbTree addValue:@1];
    [rbTree addValue:@2];
    [rbTree addValue:@3];
    [rbTree addValue:@4];
    [rbTree addValue:@5];
    [rbTree addValue:@6];
    [rbTree addValue:@7];
    [rbTree addValue:@8];
    [rbTree addValue:@9];

    
    NSLog(@"%@",rbTree);
    
    NSLog(@"中序遍历");
    [rbTree.getRootTreeNode traverseInOrder:^(int num) {
        NSLog(@"%d",num);
    }];

    NSLog(@"前序遍历");
    [rbTree.getRootTreeNode traversePreOrder:^(int num) {
        NSLog(@"%d",num);
    }];

    NSLog(@"后序遍历");
    [rbTree.getRootTreeNode traversePostOrder:^(int num) {
        NSLog(@"%d",num);
    }];
    
    NSLog(@"delete 4");
    [rbTree deleteValue:@4];
    NSLog(@"%@",rbTree);
    
}


@end
