//
//  SCCatalogMenuCell.m
//  EditMenu
//
//  Created by sobeycloud on 2017/1/4.
//  Copyright © 2017年 sobeycloud. All rights reserved.
//

#import "SCCatalogMenuCell.h"

@implementation SCCatalogMenuCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.deleteBtn.layer.cornerRadius = self.deleteBtn.frame.size.height / 2;
    self.deleteBtn.layer.masksToBounds = YES;
    self.mainTitle.layer.cornerRadius = self.mainTitle.frame.size.height / 2;
    self.mainTitle.layer.masksToBounds = YES;
    self.mainTitle.layer.borderColor = [UIColor lightGrayColor].CGColor;
    // Initialization code
}
- (IBAction)btnResponse:(id)sender {
    [[self deleteResponder] dealWithDeletedCell:self];
}

- (void)magnifyMainTitleSize {
    CATransform3D transform = CATransform3DMakeScale(1.1, 1.1, 1);
    self.mainTitle.layer.transform = transform;
}

- (void)restoreMainTitleSize {
    CATransform3D transform = CATransform3DMakeScale(1, 1, 1);
    self.mainTitle.layer.transform = transform;
}

- (void)setCellStyleZero {
    self.mainTitle.layer.borderWidth = 0;
    self.mainTitle.backgroundColor = [UIColor clearColor];
    self.deleteBtn.hidden = YES;
}

- (void)setCellStyleOne {
    self.mainTitle.layer.borderWidth = 0.5;
    self.mainTitle.backgroundColor = [UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1];
    self.deleteBtn.hidden = YES;
}

- (void)setCellStyleTwo {
    self.mainTitle.layer.borderWidth = 0.5;
    self.mainTitle.backgroundColor = [UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1];
    self.deleteBtn.hidden = NO;
}

- (void)hideSubViews {
    self.mainTitle.hidden = YES;
    self.deleteBtn.hidden = YES;
}

- (void)showSubViews {
    self.mainTitle.hidden = NO;
    self.deleteBtn.hidden = NO;
}

- (void)ajustMainTitleTextFont {
    CGFloat fontSizeThatFits;
    [self.mainTitle.text sizeWithFont:self.mainTitle.font
                 minFontSize:0.0   //最小字体
              actualFontSize:&fontSizeThatFits
                    forWidth:self.mainTitle.bounds.size.width-4
               lineBreakMode:NSLineBreakByWordWrapping];
    
    self.mainTitle.font = [self.mainTitle.font fontWithSize:fontSizeThatFits];
}

- (UIResponder<SCCatalogMenuCellDeleteProtocol> *)deleteResponder {
    UIResponder *next = self.nextResponder;
    while (next != nil) {
        if ([next respondsToSelector:@selector(dealWithDeletedCell:)]) {
            return (UIResponder<SCCatalogMenuCellDeleteProtocol> *)next;
        }
        next = next.nextResponder;
    }
    return nil;
}

- (UIResponder<SCCatalogMenuCellTouchProtocol> *)touchResponder {
    UIResponder *next = self.nextResponder;
    while (next != nil) {
        if ([next respondsToSelector:@selector(dealWithCatalogMenuCellTouch:AndType:)]) {
            return (UIResponder<SCCatalogMenuCellTouchProtocol> *)next;
        }
        next = next.nextResponder;
    }
    return nil;
}
#pragma mark - 传递cell的touch事件。
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [[self touchResponder] dealWithCatalogMenuCellTouch:[touches anyObject] AndType:SCCatalogMenuCellTouchBegan];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    [[self touchResponder] dealWithCatalogMenuCellTouch:[touches anyObject] AndType:SCCatalogMenuCellTouchMoved];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    [[self touchResponder] dealWithCatalogMenuCellTouch:[touches anyObject] AndType:SCCatalogMenuCellTouchEnded];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    [[self touchResponder] dealWithCatalogMenuCellTouch:[touches anyObject] AndType:SCCatalogMenuCellTouchCancelled];
}

@end
