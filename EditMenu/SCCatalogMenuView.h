//
//  SCCatalogMenuView.h
//  EditMenu
//
//  Created by sobeycloud on 2017/1/5.
//  Copyright © 2017年 sobeycloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SCCatalogMenuViewDelegate <NSObject>
- (void)editStateChanged:(BOOL)state;
- (void)didSelectedCurrentIndex:(NSInteger )index;
@end

@interface SCCatalogMenuView : UIView
@property(nonatomic, assign)BOOL editing;
@property(nonatomic, assign)NSInteger selectedIndex;
@property(nonatomic, strong)UIColor *selectedColor;
@property(nonatomic, strong)NSMutableArray *currentArray;
@property(nonatomic, strong)NSMutableArray *extraArray;
@property(nonatomic, weak)id<SCCatalogMenuViewDelegate> delegate;
+ (SCCatalogMenuView *)viewWithFrame:(CGRect)frame;
- (void)reloadData;
@end
