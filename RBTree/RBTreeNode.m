//
//  RBTreeNode.m
//  RBTree
//
//  Created by Myron on 2019/8/6.
//  Copyright © 2019 Myron. All rights reserved.
//

#import "RBTreeNode.h"

@implementation RBTreeNode

/** 初始化对象，并赋值节点值和节点颜色 */
+ (instancetype) treeNodeWithValue:(NSNumber*)value withColor:(NodeColor)color
{
    RBTreeNode *node = [[RBTreeNode alloc] init];
    [node setNodeValue:value];
    [node setNodeColor:color];
    return node;
}

- (void)setLeftNode:(RBTreeNode *)mLeftNode {
    if(_mLeftNode == mLeftNode) { return; }
    
    _mLeftNode = mLeftNode;
    if(_mLeftNode != nil){
        [_mLeftNode setParentNode:self]; // 弱引用
    }
}- (void)setRightNode:(RBTreeNode *)mRightNode {
    if(_mRightNode == mRightNode) { return; }
    
    _mRightNode = mRightNode;
    if(_mRightNode != nil){
        [_mRightNode setParentNode:self];
    }
}

- (NSString *)description
{
    return [self description:self withTop:@"" withRoot:@"" withBottom:@""];
}

- (NSString *)description:(RBTreeNode *)node withTop:(NSString *)top withRoot:(NSString *)root withBottom:(NSString *)bottom {
    if (node == nil) {
        return @"\n";
        NSLog(@"root %@",root);
        return [NSString stringWithFormat:@"%@%@\n",root,node.mNodeValue];
    }
    if(node.mLeftNode == nil && node.mRightNode == nil) {
        return [NSString stringWithFormat:@"%@%@%@\n",root,node.mNodeValue,node.mNodeColor == NodeColor_Red ? @"红" : @"黑"];
    }
    return [NSString stringWithFormat:@"%@%@%@",
            [self description:node.mRightNode withTop:[NSString stringWithFormat:@"%@ ",top] withRoot:[NSString stringWithFormat:@"%@┌───",top] withBottom:[NSString stringWithFormat:@"%@| ",top]],
            [NSString stringWithFormat:@"%@%@%@\n",root,node.mNodeValue,node.mNodeColor == NodeColor_Red ? @"红" : @"黑"],
            [self description:node.mLeftNode withTop:[NSString stringWithFormat:@"%@| ",bottom] withRoot:[NSString stringWithFormat:@"%@└───",bottom] withBottom:[NSString stringWithFormat:@"%@ ",bottom]]];
}

- (void)traverseInOrder:(NodeBlock)block {
    [self.mLeftNode traverseInOrder:block];
    block([self.mNodeValue intValue]);
    [self.mRightNode traverseInOrder:block];
}

-(void)traversePreOrder:(NodeBlock)block {
    block([self.mNodeValue intValue]);
    [self.mLeftNode traversePreOrder:block];
    [self.mRightNode traversePreOrder:block];
}

-(void)traversePostOrder:(NodeBlock)block {
    [self.mLeftNode traversePostOrder:block];
    [self.mRightNode traversePostOrder:block];
    block([self.mNodeValue intValue]);


}


@end
