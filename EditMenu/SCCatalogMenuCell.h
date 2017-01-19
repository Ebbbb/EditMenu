//
//  SCCatalogMenuCell.h
//  EditMenu
//
//  Created by sobeycloud on 2017/1/4.
//  Copyright © 2017年 sobeycloud. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, SCCatalogMenuCellTouchType) {
    SCCatalogMenuCellTouchBegan,
    SCCatalogMenuCellTouchMoved,
    SCCatalogMenuCellTouchEnded,
    SCCatalogMenuCellTouchCancelled
};

@protocol SCCatalogMenuCellTouchProtocol <NSObject>
- (void)dealWithCatalogMenuCellTouch:(UITouch *)touch AndType:(SCCatalogMenuCellTouchType)type;
@end

@protocol SCCatalogMenuCellDeleteProtocol <NSObject>
- (void)dealWithDeletedCell:(UICollectionViewCell *)cell;
@end

@interface SCCatalogMenuCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *mainTitle;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
- (void)magnifyMainTitleSize;
- (void)restoreMainTitleSize;
- (void)setCellStyleZero;
- (void)setCellStyleOne;
- (void)setCellStyleTwo;
- (void)hideSubViews;
- (void)showSubViews;
- (void)ajustMainTitleTextFont;
@end
