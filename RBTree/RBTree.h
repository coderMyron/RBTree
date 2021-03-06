//
//  RBTree.h
//  RBTree
//
//  Created by Myron on 2019/8/6.
//  Copyright © 2019 Myron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RBTreeNode.h"


NS_ASSUME_NONNULL_BEGIN


/** 红黑树 */
@interface RBTree : NSObject

/** 全局对象 */
+ (instancetype) sharedRBTree;

/** 添加节点值 */
- (void) addValue:(NSNumber*)value;

/** 删除节点值 */
- (void) deleteValue:(NSNumber*)value;

/** 查找节点值 */
- (RBTreeNode*) searchNodeWithParentValue:(RBTreeNode*)parentNode withSearchValue:(NSNumber*)value;

/** 获取树高度 */
- (int) getTreeHeight;

/** 获取树的根节点 */
- (RBTreeNode*) getRootTreeNode;

/** 获取某个节点的右子树高度 */
- (int) getTreeNodeRightHeight:(RBTreeNode*)treeNode;

/** 获取某个节点的左子树高度 */
- (int) getTreeNodeLeftHeight:(RBTreeNode*)treeNode;

+ (BOOL) isBrotherHaveTheRightChild:(RBTreeNode*)treeNode;

+ (BOOL) isBrotherHaveTheLeftChild:(RBTreeNode*)treeNode;



@end

NS_ASSUME_NONNULL_END
