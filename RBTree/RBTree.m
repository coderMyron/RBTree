//
//  RBTree.m
//  RBTree
//
//  Created by Myron on 2019/8/6.
//  Copyright © 2019 Myron. All rights reserved.
//

#import "RBTree.h"


@implementation RBTree
{
    RBTreeNode *mRootTreeNode;
}

#pragma mark - 全局对象
+ (instancetype)sharedRBTree {
    static RBTree *sharedRBTree = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(sharedRBTree == nil){
            sharedRBTree = [[RBTree alloc] init];
        }

    });
    return sharedRBTree;
}

#pragma mark - 获取根节点
- (RBTreeNode *)getRootTreeNode {
    return mRootTreeNode;
}

+ (BOOL)isBrotherHaveTheRightChild:(RBTreeNode *)treeNode {
    BOOL isResult = NO;
    RBTreeNode *parentNode = treeNode.getParentNode;
    if(parentNode != nil){
        RBTreeNode *brother = parentNode.getLeftNode;
        if(brother != nil){
            if(brother.getRightNode != nil){
                isResult = YES;
            }
        }
    }
    return isResult;
}

+ (BOOL)isBrotherHaveTheLeftChild:(RBTreeNode *)treeNode {
    BOOL isResult = NO;
    RBTreeNode *parentNode = treeNode.getParentNode;
    if(parentNode != nil){
        RBTreeNode *brother = parentNode.getRightNode;
        if(brother != nil){
            if(brother.getLeftNode != nil){
                isResult = YES;
            }
        }
    }
    return isResult;
}

#pragma mark - 获取树高度
- (int)getTreeHeight {
    int height = 0;
    if(mRootTreeNode == nil){
        return height;
    }
    height = [self getTreeHeightWithNode:mRootTreeNode withHeightValue:height];
    
    return height;
}

- (int) getTreeHeightWithNode:(RBTreeNode*)treeNode withHeightValue:(int)heightValue
{
    if(treeNode == nil){
        return heightValue;
    }
    heightValue += 1;
    int leftHeight = heightValue;
    int rightHeight = heightValue;
    if(treeNode.getLeftNode != nil){
        leftHeight = [self getTreeHeightWithNode:treeNode.getLeftNode withHeightValue:heightValue];
    }
    if(treeNode.getRightNode != nil){
        rightHeight = [self getTreeHeightWithNode:treeNode.getRightNode withHeightValue:heightValue];
    }
    return (leftHeight > rightHeight)? leftHeight : rightHeight;
}

#pragma mark - 获取某个节点的右子树高度
- (int) getTreeNodeRightHeight:(RBTreeNode*)treeNode
{
    int height = 0;
    if(treeNode == nil){
        return height;
    }
    height = [self getTreeNodeRightHeight:treeNode withHeightValue:height];
    return height;
}

- (int) getTreeNodeRightHeight:(RBTreeNode *)treeNode withHeightValue:(int)heightValue
{
    if(treeNode == nil){
        return heightValue;
    }
    if(treeNode.getRightNode != nil){
        heightValue += 1;
        heightValue = [self getTreeNodeRightHeight:treeNode.getRightNode withHeightValue:heightValue];
    }
    return heightValue;
}

#pragma mark - 获取某个节点的左子树高度
- (int) getTreeNodeLeftHeight:(RBTreeNode*)treeNode
{
    int height = 0;
    if(treeNode == nil){
        return height;
    }
    height = [self getTreeNodeLeftHeight:treeNode withHeightValue:height];
    return height;
}
- (int) getTreeNodeLeftHeight:(RBTreeNode *)treeNode withHeightValue:(int)heightValue
{
    if(treeNode == nil){
        return heightValue;
    }
    if(treeNode.getLeftNode != nil){
        heightValue += 1;
        heightValue = [self getTreeNodeLeftHeight:treeNode.getLeftNode withHeightValue:heightValue];
    }
    return heightValue;
}

#pragma mark - 添加节点值
- (void) addValue:(NSNumber*)value
{
    if(value == nil) { return; }
    
    RBTreeNode *nodeAdd = [RBTreeNode treeNodeWithValue:value withColor:NodeColor_Red];
    
    /** 二叉树操作 */
    if(mRootTreeNode == nil){
        mRootTreeNode = nodeAdd;
    } else {
        [self addValueWithParentNode:mRootTreeNode withNewTreeNode:nodeAdd];
    }
    
    /** 红黑树操作 */
    [self handleRBTreeForAddNode:nodeAdd];
}

- (void) addValueWithParentNode:(RBTreeNode*)parentNode withNewTreeNode:(RBTreeNode*)newTreeNode
{
    /** 二叉树的插入操作 */
    if([parentNode.getNodeValue compare:newTreeNode.getNodeValue] == NSOrderedSame
       || [parentNode.getNodeValue compare:newTreeNode.getNodeValue] == NSOrderedDescending){ // 左节点
        
        if(parentNode.getLeftNode == nil){ // 如果左孩子为空，直接赋值
            [parentNode setLeftNode:newTreeNode];
        } else {
            [self addValueWithParentNode:parentNode.getLeftNode withNewTreeNode:newTreeNode];
        }
        
    } else { // 右节点
        if(parentNode.getRightNode == nil){ // 如果右孩子为空，直接赋值
            [parentNode setRightNode:newTreeNode];
        } else {
            [self addValueWithParentNode:parentNode.getRightNode withNewTreeNode:newTreeNode];
        }
    }
}

#pragma mark -  根据当前指向的节点调整红黑树
- (void) handleRBTreeForAddNode:(RBTreeNode*)treeNode
{
    /** 情况1：红黑树只有一个根节点 */
    if(treeNode == mRootTreeNode){ // 如果是根节点，那么直接将节点变黑即可
        [treeNode setNodeColor:NodeColor_Black];
        return;
    }
    /** 以下情况则必定存在父节点 */
    /** 情况2：当前节点的父节点为黑色 */
    if(treeNode.getParentNode.getNodeColor == NodeColor_Black){ // 符合红黑树规则，不需要处理
        return;
    }
    
    /** 以下情况父节点必定是红色，所以按照红黑树规则，必定存在祖父节点（规则：红黑树的根节点必是黑色） */
    RBTreeNode *parentNode = treeNode.getParentNode; // 父节点
    RBTreeNode *grandfatherNode = parentNode.getParentNode; // 祖父节点
    BOOL isLeftForParentNodeToGrandfather = (grandfatherNode.getLeftNode == parentNode)? YES : NO; // 父节点是左节点还是右节点，这个决定处理红黑树旋转的方向
    RBTreeNode *uncleNode = (isLeftForParentNodeToGrandfather == YES)? grandfatherNode.getRightNode : grandfatherNode.getLeftNode; // 叔叔节点`
    BOOL isLeftForCurrentNodeToParent = (parentNode.getLeftNode == treeNode)? YES : NO; // 当前节点是左节点还是右节点
    
    /** 情况3：当前节点的父节点为红色，而叔叔节点也为红色（祖父节点和叔叔节点不为空） */
    if(parentNode.getNodeColor == NodeColor_Red
       && uncleNode != nil
       && uncleNode.getNodeColor == NodeColor_Red){
        // 把父节点、叔叔节点都变为黑，祖父节点变为红，然后当前节点指针指向祖父节点再继续监测红黑树
        [parentNode setNodeColor:NodeColor_Black];
        [uncleNode setNodeColor:NodeColor_Black];
        [grandfatherNode setNodeColor:NodeColor_Red];
        return [self handleRBTreeForAddNode:grandfatherNode];
    }
    
    /** 情况4：当前节点的父节点为红色，而叔叔节点为黑色，或者为空 */
    if(parentNode.getNodeColor == NodeColor_Red
       && (uncleNode == nil || uncleNode.getNodeColor == NodeColor_Black)){
        
        if(isLeftForParentNodeToGrandfather == YES){ // 父节点是祖父节点的左孩子
            if(isLeftForCurrentNodeToParent == YES){ // 当前节点是父节点的左孩子，这时候只需要把父节点变为黑，祖父节点变成红，当前节点指向祖父节点，并在祖父节点向右旋转
                [parentNode setNodeColor:NodeColor_Black];
                [grandfatherNode setNodeColor:NodeColor_Red];
                [self nodeRotate_toRight:grandfatherNode];
                return [self handleRBTreeForAddNode:grandfatherNode];
            } else { // 当前节点是父节点的右孩子，那么先把当前节点指向父节点，然后在父节点左旋
                [self nodeRotate_toLeft:parentNode];
                return [self handleRBTreeForAddNode:parentNode];
            }
            
        } else { // 父节点是祖父节点的右孩子
            if(isLeftForCurrentNodeToParent == YES){// 当前节点是父节点的左孩子，那么先把当前节点指向父节点，然后在父节点右旋
                [self nodeRotate_toRight:parentNode];
                return [self handleRBTreeForAddNode:parentNode];
                
            } else {// 当前节点是父节点的右孩子，这时候只需要把父节点变为黑，祖父节点变成红，当前节点指向祖父节点，并在祖父节点向左旋转
                [parentNode setNodeColor:NodeColor_Black];
                [grandfatherNode setNodeColor:NodeColor_Red];
                [self nodeRotate_toLeft:grandfatherNode];
                return [self handleRBTreeForAddNode:grandfatherNode];
            }
        }
    }
    [mRootTreeNode setParentNode:nil];
}

#pragma mark - 节点旋转 - 向右旋转
- (void) nodeRotate_toRight:(RBTreeNode*)treeNode
{
    RBTreeNode *leftChildTreeNode = [treeNode getLeftNode]; // 当前节点的左孩子
    RBTreeNode *parentTreeNode = [treeNode getParentNode];
    if(parentTreeNode != nil
       && treeNode != mRootTreeNode){
        if(parentTreeNode.getLeftNode == treeNode){
            [parentTreeNode setLeftNode:leftChildTreeNode];
        } else {
            [parentTreeNode setRightNode:leftChildTreeNode];
        }
    } else { // 根节点
        mRootTreeNode = leftChildTreeNode;
        [mRootTreeNode setParentNode:nil];
    }
    
    RBTreeNode *rightForChildTreeNode = [leftChildTreeNode getRightNode]; // 左孩子的右孩子
    [treeNode setLeftNode:rightForChildTreeNode];
    [leftChildTreeNode setRightNode:treeNode];
}

#pragma mark - 节点旋转 - 向左旋转
- (void) nodeRotate_toLeft:(RBTreeNode*)treeNode
{
    RBTreeNode *rightChildTreeNode = [treeNode getRightNode]; // 当前节点的右孩子
    RBTreeNode *parentTreeNode = [treeNode getParentNode];
    if(parentTreeNode != nil
       && treeNode != mRootTreeNode){
        if(parentTreeNode.getLeftNode == treeNode){
            [parentTreeNode setLeftNode:rightChildTreeNode];
        } else {
            [parentTreeNode setRightNode:rightChildTreeNode];
        }
    } else { // 根节点
        mRootTreeNode = rightChildTreeNode;
        [mRootTreeNode setParentNode:nil];
    }
    
    RBTreeNode *leftForChildTreeNode = [rightChildTreeNode getLeftNode]; // 右孩子的左孩子
    [treeNode setRightNode:leftForChildTreeNode];
    [rightChildTreeNode setLeftNode:treeNode];
}

#pragma mark - 查找节点
- (RBTreeNode*) searchNodeWithParentValue:(RBTreeNode*)parentNode withSearchValue:(NSNumber*)value
{
    RBTreeNode *nodeResult = nil;
    if(parentNode == nil) {
        return nodeResult;
    }
    if([parentNode.mNodeValue compare:value] == NSOrderedSame){
        nodeResult = parentNode;
        
    } else if([parentNode.mNodeValue compare:value] == NSOrderedAscending){ // 上升，值比父节点大，右孩子
        nodeResult = [self searchNodeWithParentValue:parentNode.getRightNode withSearchValue:value];
        
    } else if([parentNode.mNodeValue compare:value] == NSOrderedDescending){ // 下降，值比父节点小，左孩子
        nodeResult = [self searchNodeWithParentValue:parentNode.getLeftNode withSearchValue:value];
        
    }
    return nodeResult;
}

#pragma mark - 找到该节点中最小的节点
- (RBTreeNode*) getMinValueNodeOfParentNode:(RBTreeNode*)parentNode
{
    if(parentNode == nil){
        return nil;
    }
    
    if(parentNode.getLeftNode == nil){
        return parentNode;
    }
    return [self getMinValueNodeOfParentNode:parentNode.getLeftNode];
}

#pragma mark - 找到该节点中最大的节点
- (RBTreeNode*) getMaxValueNodeOfParentNode:(RBTreeNode*)parentNode
{
    if(parentNode.getRightNode == nil){
        return parentNode;
    }
    return [self getMaxValueNodeOfParentNode:parentNode.getRightNode];
}

#pragma mark - 删除节点值
- (void) deleteValue:(NSNumber*)value
{
    // ====== 先按照二叉树的方式删除节点，然后在调整红黑树 ======
    RBTreeNode *deleteNode = [self searchNodeWithParentValue:mRootTreeNode withSearchValue:value];
    if(deleteNode == nil) { return; } // 找不到待删除的节点
    
    BOOL isLeftOrRightReplace = (deleteNode.getLeftNode != nil)? YES : NO;
    RBTreeNode *replaceNode = (isLeftOrRightReplace == YES)? [self getMaxValueNodeOfParentNode:deleteNode.getLeftNode] : [self getMinValueNodeOfParentNode:deleteNode.getRightNode]; // 替换节点：左子树中最大的节点，或者是右子树中最小的节点
    // 开始删除
    RBTreeNode *parentForReplaceNode = nil;
    RBTreeNode *brotherForReplaceNode = nil;
    BOOL isLeftOfParentNodeForCurrentNode = YES;
    if(replaceNode != nil){
        parentForReplaceNode = replaceNode.getParentNode;
        if(parentForReplaceNode.getLeftNode == replaceNode){
            brotherForReplaceNode = parentForReplaceNode.getRightNode;
            isLeftOfParentNodeForCurrentNode = YES;
        } else {
            brotherForReplaceNode = parentForReplaceNode.getLeftNode;
            isLeftOfParentNodeForCurrentNode = NO;
        }
        
        if(isLeftOrRightReplace == YES){
            // 左孩子树中最大的，所以必没有右孩子
            // 删除左孩子树中最大的
            if (parentForReplaceNode != deleteNode) {
                [parentForReplaceNode setRightNode:replaceNode.getLeftNode];
            }
            
        } else {
            // 右子树中最小的，所以必没有左孩子
            // 删除右子树中最小的
            if (parentForReplaceNode != deleteNode) {
                [parentForReplaceNode setLeftNode:replaceNode.getRightNode];
            }
            
        }
    }
    
    // ====== 开始调整红黑树规则 ======
    [self handleRBTreeForDeleteNode:parentForReplaceNode
                    withCurrentNode:replaceNode
                    withBrotherNode:brotherForReplaceNode
                  withIsLeftOrRight:isLeftOfParentNodeForCurrentNode
                     withDeleteNode:deleteNode];
    
    // 替换节点颜色换为删除的颜色
    [replaceNode setNodeColor:deleteNode.getNodeColor];

    
    
    BOOL isRootForDeleteNode = (deleteNode == mRootTreeNode)? YES : NO;
    if (isLeftOrRightReplace == YES ) {
        //判断左孩子树中最大值的父节点不是删除节点
        if (replaceNode != deleteNode.getLeftNode) {
            [replaceNode setLeftNode:deleteNode.getLeftNode];
        }
        [replaceNode setRightNode:deleteNode.getRightNode];
        
    }else {
        //右子树中最小的值的父节点不是删除节点
        if (replaceNode != deleteNode.getRightNode) {
            [replaceNode setRightNode:deleteNode.getRightNode];
        }
        [replaceNode setLeftNode:deleteNode.getLeftNode];
    }
    
    [deleteNode setLeftNode:nil];
    [deleteNode setRightNode:nil];
    if(isRootForDeleteNode == YES){
        mRootTreeNode = replaceNode;
    } else {
        RBTreeNode *parentForDeleteNode = deleteNode.getParentNode;
        BOOL bIsLeftOrRight = (parentForDeleteNode.getLeftNode == deleteNode)? YES : NO;
        if(bIsLeftOrRight == YES){
            [parentForDeleteNode setLeftNode:replaceNode];
        } else {
            [parentForDeleteNode setRightNode:replaceNode];
        }
    }
    
}

- (void) handleRBTreeForDeleteNode:(RBTreeNode*)parentNodeForCurrentNode
                   withCurrentNode:(RBTreeNode*)currentNode
                   withBrotherNode:(RBTreeNode*)brotherForCurrentNode
                 withIsLeftOrRight:(BOOL)isLeftOfParentNodeForCurrentNode
                    withDeleteNode:(RBTreeNode*)deleteNode
{
    
    
    /**
     替换结点是红色结点
     我们把替换结点换到了删除结点的位置时，由于替换结点时红色，删除也了不会影响红黑树的平衡，
     只要把替换结点的颜色设为删除的结点的颜色即可重新平衡。
     */
    if (currentNode.getNodeColor == NodeColor_Red) {
        [currentNode setNodeColor:deleteNode.getNodeColor];
        return ;
    }
    
    [self handleRBTreeForDeleteNode:parentNodeForCurrentNode
                    withCurrentNode:currentNode
                    withBrotherNode:brotherForCurrentNode
                  withIsLeftOrRight:isLeftOfParentNodeForCurrentNode];
    
}

- (void) handleRBTreeForDeleteNode:(RBTreeNode*)parentNodeForCurrentNode
                   withCurrentNode:(RBTreeNode*)currentNode
                   withBrotherNode:(RBTreeNode*)brotherForCurrentNode
                 withIsLeftOrRight:(BOOL)isLeftOfParentNodeForCurrentNode
{
    /**
     下面针对当前节点是父节点的左孩子的情况讨论，当前节点是右孩子的话，旋转就相反
     情况1：当前节点的兄弟节点为红色，则根据从任意节点出发，各个分子的黑高度是一样的规则，那么兄弟节点的孩子树中必有黑节点，则把兄弟节点变为黑，父节点变为红，然后以父节点左旋，旋转之后，兄弟节点的左孩子则变成当前节点的兄弟节点（变成情况2）。
     情况2：兄弟节点为黑，其子孩子都为黑，那么则把兄弟节点变为红，然后当前节点移到其父节点。
     情况3：兄弟节点为黑，其左孩子为红，右孩子为黑，那么则把左孩子变黑，兄弟节点变红，然后在兄弟节点右旋，这样当前节点的兄弟节点则变成了右转后的左节点（变成情况4）
     情况4：兄弟节点为黑，其右孩子为红，那么则把兄弟节点的颜色变成其父节点的颜色，而父节点的颜色变成黑，兄弟节点的右孩子变为红，在父节点左旋
     情况5：兄弟节点为空，则直接把当前节点指向其父节点再处理
     */
    
    if(currentNode != mRootTreeNode
       && currentNode.getNodeColor == NodeColor_Black)
    {
        RBTreeNode *grandFatherNode = parentNodeForCurrentNode.getParentNode; // 不是根节点，则必存在父节点
        RBTreeNode *uncleNode = nil;
        BOOL isLeftOrRightForGrandFather = YES;
        if(grandFatherNode == nil){
            isLeftOrRightForGrandFather = YES;
            uncleNode = nil;
            
        } else if(grandFatherNode.getLeftNode == parentNodeForCurrentNode){
            isLeftOrRightForGrandFather = YES;
            uncleNode = grandFatherNode.getRightNode;
            
        } else {
            isLeftOrRightForGrandFather = NO;
            uncleNode = grandFatherNode.getLeftNode;
        }
        
        // ======= 先处理没有旋转的情况 =======
        if(brotherForCurrentNode == nil){ // 情况5
            [self handleRBTreeForDeleteNode:grandFatherNode withCurrentNode:parentNodeForCurrentNode withBrotherNode:uncleNode withIsLeftOrRight:isLeftOrRightForGrandFather];
            
        } else if(brotherForCurrentNode.getNodeColor == NodeColor_Black
                  && ( brotherForCurrentNode.getLeftNode == nil || brotherForCurrentNode.getLeftNode.getNodeColor == NodeColor_Black )
                  && ( brotherForCurrentNode.getRightNode == nil || brotherForCurrentNode.getRightNode.getNodeColor == NodeColor_Black) )
        {   // 情况2
            [brotherForCurrentNode setNodeColor:NodeColor_Red];
            [self handleRBTreeForDeleteNode:grandFatherNode withCurrentNode:parentNodeForCurrentNode withBrotherNode:uncleNode withIsLeftOrRight:isLeftOrRightForGrandFather];
            
        }
        // ======= 接下来处理需要进行旋转的情况 =======
        else if(isLeftOfParentNodeForCurrentNode == YES){ // 当前节点是左孩子：接下来的情况需要进行旋转， 则需要判断当前节点是左孩子还是右孩子
            if(brotherForCurrentNode.getNodeColor == NodeColor_Red){ // 情况1
                [brotherForCurrentNode setNodeColor:NodeColor_Black];
                [parentNodeForCurrentNode setNodeColor:NodeColor_Red];
                [self nodeRotate_toLeft:parentNodeForCurrentNode];
                [self handleRBTreeForDeleteNode:parentNodeForCurrentNode withCurrentNode:currentNode withBrotherNode:parentNodeForCurrentNode.getRightNode withIsLeftOrRight:isLeftOfParentNodeForCurrentNode];
                
            } else if(brotherForCurrentNode.getNodeColor == NodeColor_Black
                      && (brotherForCurrentNode.getLeftNode != nil && brotherForCurrentNode.getLeftNode.getNodeColor == NodeColor_Red)
                      && (brotherForCurrentNode.getRightNode == nil || brotherForCurrentNode.getRightNode.getNodeColor == NodeColor_Black))
            {   // 情况3
                [brotherForCurrentNode.getLeftNode setNodeColor:NodeColor_Black];
                [brotherForCurrentNode setNodeColor:NodeColor_Red];
                [self nodeRotate_toRight:brotherForCurrentNode];
                [self handleRBTreeForDeleteNode:parentNodeForCurrentNode
                                withCurrentNode:currentNode
                                withBrotherNode:parentNodeForCurrentNode.getRightNode
                              withIsLeftOrRight:isLeftOfParentNodeForCurrentNode];
                
            } else if(brotherForCurrentNode.getNodeColor == NodeColor_Black
                      && (brotherForCurrentNode.getRightNode != nil && brotherForCurrentNode.getRightNode.getNodeColor == NodeColor_Red))
            {   // 情况4
                [brotherForCurrentNode setNodeColor:[parentNodeForCurrentNode getNodeColor]];
                [parentNodeForCurrentNode setNodeColor:NodeColor_Black];
                [brotherForCurrentNode.getRightNode setNodeColor:NodeColor_Black];
                [self nodeRotate_toLeft:parentNodeForCurrentNode];
                [self handleRBTreeForDeleteNode:parentNodeForCurrentNode
                                withCurrentNode:currentNode
                                withBrotherNode:parentNodeForCurrentNode.getRightNode
                              withIsLeftOrRight:YES];
            }
            
        } else if(isLeftOfParentNodeForCurrentNode != YES){ // 当前节点是右孩子
            if(brotherForCurrentNode.getNodeColor == NodeColor_Red){ // 情况1
                [brotherForCurrentNode setNodeColor:NodeColor_Black];
                [parentNodeForCurrentNode setNodeColor:NodeColor_Red];
                [self nodeRotate_toRight:parentNodeForCurrentNode];
                [self handleRBTreeForDeleteNode:parentNodeForCurrentNode withCurrentNode:currentNode withBrotherNode:parentNodeForCurrentNode.getLeftNode withIsLeftOrRight:isLeftOfParentNodeForCurrentNode];
                
            } else if(brotherForCurrentNode.getNodeColor == NodeColor_Black
                      && (brotherForCurrentNode.getRightNode != nil && brotherForCurrentNode.getRightNode.getNodeColor == NodeColor_Red)
                      && (brotherForCurrentNode.getLeftNode == nil || brotherForCurrentNode.getLeftNode.getNodeColor == NodeColor_Black))
            {   // 情况3
                [brotherForCurrentNode.getRightNode setNodeColor:NodeColor_Black];
                [brotherForCurrentNode setNodeColor:NodeColor_Red];
                [self nodeRotate_toLeft:brotherForCurrentNode];
                [self handleRBTreeForDeleteNode:parentNodeForCurrentNode
                                withCurrentNode:currentNode
                                withBrotherNode:parentNodeForCurrentNode.getLeftNode
                              withIsLeftOrRight:isLeftOfParentNodeForCurrentNode];
                
            } else if(brotherForCurrentNode.getNodeColor == NodeColor_Black
                      && (brotherForCurrentNode.getLeftNode != nil && brotherForCurrentNode.getLeftNode.getNodeColor == NodeColor_Red))
            {   // 情况4
                [brotherForCurrentNode setNodeColor:[parentNodeForCurrentNode getNodeColor]];
                [parentNodeForCurrentNode setNodeColor:NodeColor_Black];
                [brotherForCurrentNode.getLeftNode setNodeColor:NodeColor_Black];
                [self nodeRotate_toRight:parentNodeForCurrentNode];
                [self handleRBTreeForDeleteNode:parentNodeForCurrentNode
                                withCurrentNode:currentNode
                                withBrotherNode:parentNodeForCurrentNode.getLeftNode
                              withIsLeftOrRight:isLeftOfParentNodeForCurrentNode];
            }
            
        }
    }

//    [currentNode setNodeColor:NodeColor_Black];
    if (currentNode.getNodeColor == NodeColor_Red) {
        if ((currentNode.getLeftNode != nil && currentNode.getLeftNode.getNodeColor == NodeColor_Red) || (currentNode.getRightNode != nil && currentNode.getRightNode.getNodeColor == NodeColor_Red)) {
            [currentNode setNodeColor:NodeColor_Black];
        }
    }
    
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@", self.getRootTreeNode ? self.getRootTreeNode : @"empty tree"];
}

@end
