//
//  SCCatalogMenuView.m
//  EditMenu
//
//  Created by sobeycloud on 2017/1/5.
//  Copyright © 2017年 sobeycloud. All rights reserved.
//

#import "SCCatalogMenuView.h"
#import "SCCatalogMenuCell.h"

@interface SCCatalogMenuView ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,SCCatalogMenuCellTouchProtocol,SCCatalogMenuCellDeleteProtocol>
@property(nonatomic, strong)UICollectionView *collectionView;
@property(nonatomic, strong)NSMutableArray *cellAttributesArray;
@property(nonatomic, strong)NSIndexPath *sourceIndexPath;
@property(nonatomic, strong)NSIndexPath *destinationIndexPath;
@property(nonatomic, strong)SCCatalogMenuCell *fakeCell;
@property(nonatomic, strong)NSTimer *timer;
@end

@implementation SCCatalogMenuView

- (NSMutableArray *)cellAttributesArray {
    if (!_cellAttributesArray) {
        _cellAttributesArray = [NSMutableArray array];
    }
    return _cellAttributesArray;
}

- (void)setEditing:(BOOL)editing {
    _editing = editing;
    [self reloadData];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.collectionView.frame = self.bounds;
}

+ (SCCatalogMenuView *)viewWithFrame:(CGRect)frame {
    SCCatalogMenuView *view = [[SCCatalogMenuView alloc] initWithFrame:frame];
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumLineSpacing = 10;
    CGFloat itemSpace = (frame.size.width - 30 - 74 * 4) / 3;
    layout.minimumInteritemSpacing = itemSpace > 0 ? itemSpace : 0;
    layout.sectionInset = UIEdgeInsetsMake(0, 15, 0, 15);
    view.collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) collectionViewLayout:layout];
    [view.collectionView registerNib:[UINib nibWithNibName:@"SCCatalogMenuCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"cell"];
    [view.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"section"];
    view.collectionView.backgroundColor = [UIColor whiteColor];
    view.collectionView.delegate = view;
    view.collectionView.dataSource = view;
    view.fakeCell = [[NSBundle mainBundle] loadNibNamed:@"SCCatalogMenuCell" owner:nil options:nil].lastObject;
    view.fakeCell.deleteBtn.layer.cornerRadius = view.fakeCell.deleteBtn.frame.size.height / 2;
    view.fakeCell.deleteBtn.layer.masksToBounds = YES;
    view.fakeCell.mainTitle.layer.cornerRadius = view.fakeCell.mainTitle.frame.size.height / 2;
    view.fakeCell.mainTitle.layer.masksToBounds = YES;
    view.fakeCell.mainTitle.layer.borderColor = [UIColor lightGrayColor].CGColor;
    view.fakeCell.mainTitle.layer.borderWidth = 0.5;
    
    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:view action:@selector(handlelongGesture:)];
    [view.collectionView addGestureRecognizer:longGesture];
    [view addSubview:view.collectionView];
    return view;
}

- (void)reloadData {
    [self.collectionView reloadData];
    if (!self.editing) {
        [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:self.selectedIndex inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    }
}

#pragma mark - 处理长按手势,进入编辑状态
- (void)handlelongGesture:(UILongPressGestureRecognizer *)longGesture{
    if (!self.editing) {
        self.editing = YES;
        if ([self.delegate respondsToSelector:@selector(editStateChanged:)]) {
            [self.delegate editStateChanged:YES];
        }
    }
}

#pragma mark - 删除cell
-(void)dealWithDeletedCell:(UICollectionViewCell *)cell {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    [self.extraArray insertObject:self.currentArray[indexPath.row] atIndex:0];
    [self.currentArray removeObjectAtIndex:indexPath.row];
    [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
}

#pragma mark - 拖拽cell
- (void)dealWithCatalogMenuCellTouch:(UITouch *)touch AndType:(SCCatalogMenuCellTouchType)type {
    if (!self.editing) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    static SCCatalogMenuCell *cell;
    switch (type) {
        case SCCatalogMenuCellTouchBegan:{
            self.collectionView.panGestureRecognizer.enabled = NO;
            CGPoint point = [touch locationInView:self.collectionView];
            //在touch事件开始的时候获取起始的indexpath
            self.sourceIndexPath = [self.collectionView indexPathForItemAtPoint:point];
            if (self.sourceIndexPath.row == 0) {
                return;
            }
            //拿到起始indexpath对应的视图，隐藏子视图
            cell = (SCCatalogMenuCell *)[self.collectionView cellForItemAtIndexPath:self.sourceIndexPath];
            [cell hideSubViews];
            //使用一个另外一个手动创建的cell来占位
            self.fakeCell.frame = cell.frame;
            self.fakeCell.mainTitle.text = cell.mainTitle.text;
            [self.fakeCell magnifyMainTitleSize];
            [self.collectionView addSubview:self.fakeCell];
            //记录所有item的attributes
            [self.cellAttributesArray removeAllObjects];
            for (int i = 0; i < self.currentArray.count; i++) {
                [self.cellAttributesArray addObject:[_collectionView layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]]];
            }
        }
            break;
        case SCCatalogMenuCellTouchMoved:{
            if (self.sourceIndexPath.row == 0) {
                return;
            }
            //这里我们这个虚假的cell来代替起始位置的cell做移动
            self.fakeCell.center = [touch locationInView:_collectionView];
            //为了模仿interective recording还需要添加一个timer来处理我们手势位置到达上下边界时需要移动collectionview
            if ((self.fakeCell.center.y >= self.collectionView.contentOffset.y && self.fakeCell.center.y < self.collectionView.contentOffset.y + 25) || (self.fakeCell.center.y > self.collectionView.contentOffset.y + self.collectionView.frame.size.height - 25 && self.fakeCell.center.y <= self.collectionView.contentOffset.y + self.collectionView.frame.size.height)) {
                [self startTimer];
            }
            else {
                [self pauseTimer];
            }
            //这里使需要注意的地方，超出可视范围的地方需要屏蔽掉，会出bug。
            if (self.fakeCell.center.y > self.collectionView.frame.size.height + self.collectionView.contentOffset.y || self.fakeCell.center.y < self.collectionView.contentOffset.y) {
                break;
            }
            //这个是检测移动的方法，在timer的回调中也是要复用的
            [self checkAndMoveIndexPath];
        }
            break;
        case SCCatalogMenuCellTouchEnded:{
            if (self.sourceIndexPath.row == 0) {
                self.sourceIndexPath = nil;
                return;
            }
            [self pauseTimer];
            self.collectionView.panGestureRecognizer.enabled = YES;
            if (!self.destinationIndexPath) {
                //这里处理有目标indexPath的情况
                [UIView animateWithDuration:0.2 animations:^{
                    weakSelf.fakeCell.center = [_collectionView layoutAttributesForItemAtIndexPath:self.sourceIndexPath].center;
                } completion:^(BOOL finished) {
                    [weakSelf.fakeCell restoreMainTitleSize];
                    [weakSelf.fakeCell removeFromSuperview];
                    [cell showSubViews];
                    weakSelf.sourceIndexPath = nil;
                }];
            }
            else {
                //如果有目标indexPath，更新一下移动后的数据
                id obj = self.currentArray[self.sourceIndexPath.row];
                [self.currentArray removeObjectAtIndex:self.sourceIndexPath.row];
                [self.currentArray insertObject:obj atIndex:self.destinationIndexPath.row];
                [UIView animateWithDuration:0.2 animations:^{
                    weakSelf.fakeCell.center = [_collectionView layoutAttributesForItemAtIndexPath:self.destinationIndexPath].center;
                } completion:^(BOOL finished) {
                    [weakSelf.fakeCell restoreMainTitleSize];
                    [weakSelf.fakeCell removeFromSuperview];
                    [cell showSubViews];
                    weakSelf.destinationIndexPath = nil;
                    weakSelf.sourceIndexPath = nil;
                }];
            }
        }
            break;
        case SCCatalogMenuCellTouchCancelled:{
            //这里处理手势取消的情况
            if (self.sourceIndexPath.row == 0) {
                self.sourceIndexPath = nil;
                return;
            }
            [self pauseTimer];
            self.collectionView.panGestureRecognizer.enabled = YES;
            [UIView animateWithDuration:0.2 animations:^{
                weakSelf.fakeCell.center = [_collectionView layoutAttributesForItemAtIndexPath:self.sourceIndexPath].center;
            } completion:^(BOOL finished) {
                [weakSelf.fakeCell restoreMainTitleSize];
                [weakSelf.fakeCell removeFromSuperview];
                [cell showSubViews];
                weakSelf.sourceIndexPath = nil;
            }];
        }
            break;
        default:
            break;
    }
}
#pragma mark - cell移动位置
- (void)checkAndMoveIndexPath {
    for (UICollectionViewLayoutAttributes *attributes in self.cellAttributesArray) {
        if (attributes.indexPath.row != 0 && CGRectContainsPoint(attributes.frame, self.fakeCell.center)) {
            if (!self.destinationIndexPath && attributes.indexPath != self.sourceIndexPath) {
                [self.collectionView moveItemAtIndexPath:self.sourceIndexPath toIndexPath:attributes.indexPath];
                self.destinationIndexPath = attributes.indexPath;
            }
            else if (self.destinationIndexPath && attributes.indexPath != self.destinationIndexPath) {
                [self.collectionView moveItemAtIndexPath:self.destinationIndexPath toIndexPath:attributes.indexPath];
                self.destinationIndexPath = attributes.indexPath;
            }
        }
    }
}
#pragma mark - timer处理
- (void)responseToTimer {
    if (self.fakeCell.center.y < self.collectionView.contentOffset.y + 25) {
        if (self.collectionView.contentOffset.y < 5) {
            self.fakeCell.center = CGPointMake(self.fakeCell.center.x, self.fakeCell.center.y - self.collectionView.contentOffset.y);
            self.collectionView.contentOffset = CGPointZero;
        }
        else {
            self.fakeCell.center = CGPointMake(self.fakeCell.center.x, self.fakeCell.center.y - 5);
            self.collectionView.contentOffset = CGPointMake(0, self.collectionView.contentOffset.y - 5);
        }
        [self checkAndMoveIndexPath];
    }
    else if (self.fakeCell.center.y > self.collectionView.contentOffset.y + self.collectionView.frame.size.height - 25) {
        if (self.collectionView.contentOffset.y + self.collectionView.frame.size.height > self.collectionView.contentSize.height - 5) {
            self.fakeCell.center = CGPointMake(self.fakeCell.center.x, self.fakeCell.center.y + (self.collectionView.contentSize.height - self.collectionView.contentOffset.y - self.collectionView.frame.size.height));
            self.collectionView.contentOffset = CGPointMake(0, self.collectionView.contentSize.height - self.collectionView.frame.size.height);
        }
        else {
            self.fakeCell.center = CGPointMake(self.fakeCell.center.x, self.fakeCell.center.y + 5);
            self.collectionView.contentOffset = CGPointMake(0, self.collectionView.contentOffset.y + 5);
        }
        [self checkAndMoveIndexPath];
    }
}

- (void)startTimer {
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(responseToTimer) userInfo:nil repeats:YES];
    }
    _timer.fireDate = [NSDate date];
}

- (void)pauseTimer {
    _timer.fireDate = [NSDate distantFuture];
}

- (void)stopTimer {
    [self pauseTimer];
    [_timer invalidate];
    _timer = nil;
}

#pragma mark - layout 代理
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.currentArray.count) {
        return CGSizeMake(self.collectionView.frame.size.width - 30, 30);
    }
    else {
        if (!self.editing && indexPath.row == self.currentArray.count - 1) {
            CGFloat itemSpace = (self.collectionView.frame.size.width - 30 - 74 * 4) / 3;
            if (itemSpace > 0) {
                NSInteger count = 3 - (indexPath.row % 4);
                CGFloat margin = (self.collectionView.frame.size.width - 74 * 4 - 30) / 3;
                return CGSizeMake(74 + count * (74 + margin), 40);
            }else {
                NSInteger count = 2 - (indexPath.row % 3);
                CGFloat margin = (self.collectionView.frame.size.width - 74 * 3 - 30) / 2;
                return CGSizeMake(74 + count * (74 + margin), 40);
            }
        }
        return CGSizeMake(74, 40);
    }
}

#pragma mark - collectionview 代理
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.editing) {
        return self.currentArray.count;
    }
    else {
        return self.currentArray.count + self.extraArray.count + 1;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.currentArray.count) {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"section" forIndexPath:indexPath];
        if (![cell viewWithTag:100]) {
            UILabel *bg = [[UILabel alloc] initWithFrame:CGRectMake(-15, 0, self.collectionView.frame.size.width, cell.frame.size.height)];
            bg.backgroundColor = [UIColor colorWithRed:234/255.0 green:237/255.0 blue:243/255.0 alpha:1];
            [cell addSubview:bg];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
            label.font = [UIFont systemFontOfSize:14];
            label.text = @"点击添加更多栏目";
            [cell addSubview:label];
        }
        return cell;
    }
    else {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
        SCCatalogMenuCell *newCell = (SCCatalogMenuCell *)cell;
        if (self.editing) {
            if (indexPath.row == 0) {
                newCell.deleteBtn.hidden = YES;
                [newCell setCellStyleZero];
            }
            else {
                [newCell setCellStyleTwo];
            }
            newCell.mainTitle.textColor = [UIColor colorWithRed:100/255.0 green:100/255.0 blue:100/255.0 alpha:1];
        }
        else {
            if (indexPath.row == 0) {
                [newCell setCellStyleZero];
            }
            else {
                [newCell setCellStyleOne];
            }
            if (indexPath.row == self.selectedIndex) {
                if (self.selectedColor) {
                    newCell.mainTitle.textColor = self.selectedColor;
                }
                else {
                    newCell.mainTitle.textColor = [UIColor redColor];
                }
            }
        }
        [newCell ajustMainTitleTextFont];
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.currentArray.count) {
        if (!self.editing && [self.delegate respondsToSelector:@selector(didSelectedCurrentIndex:)]) {
            [self.delegate didSelectedCurrentIndex:indexPath.row];
        }
    }
    else if (indexPath.row > self.currentArray.count) {
        NSInteger index = indexPath.row - self.currentArray.count - 1;
        [self.currentArray addObject:self.extraArray[index]];
        [self.extraArray removeObjectAtIndex:index];
        [self.collectionView moveItemAtIndexPath:indexPath toIndexPath:[NSIndexPath indexPathForItem:self.currentArray.count - 1 inSection:0]];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
