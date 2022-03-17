//
//  UITextView+placeholder.m
//
//  Created by 陈振奎 on 2022/3/15.
//

#import "UITextView+placeholder.h"
#import <objc/runtime.h>

@implementation UITextView (placeholder)

+(void)load{
    method_exchangeImplementations(class_getInstanceMethod(self.class, NSSelectorFromString(@"layoutSubviews")),
                                   class_getInstanceMethod(self.class, @selector(placeHolder_layoutSubviews)));
    method_exchangeImplementations(class_getInstanceMethod(self.class, NSSelectorFromString(@"initWithFrame:")),
                                   class_getInstanceMethod(self.class, @selector(placeHolder_initWithFrame:)));
    method_exchangeImplementations(class_getInstanceMethod(self.class, NSSelectorFromString(@"setFont:")),
                                   class_getInstanceMethod(self.class, @selector(placeHolder_setFont:)));
    method_exchangeImplementations(class_getInstanceMethod(self.class, NSSelectorFromString(@"setTextAlignment:")),
                                   class_getInstanceMethod(self.class, @selector(placeHolder_setTextAlignment:)));
}

#pragma mark - associated
-(NSString *)placeholder{
    return objc_getAssociatedObject(self, _cmd);
}

-(void)setPlaceholder:(NSString *)placeholder{
    objc_setAssociatedObject(self, @selector(placeholder), placeholder, OBJC_ASSOCIATION_COPY_NONATOMIC);
    self.placeLabel.text = self.placeholder;
    if (self.placeholder.length) {
        [self addNotification];
    }
    if (self.placeholder.length && ![self.placeLabel isDescendantOfView:self] && !self.text.length) {
        [self insertSubview:self.placeLabel atIndex:0];
    }
}

-(UILabel *)placeLabel{
    return objc_getAssociatedObject(self, _cmd);
}

-(void)setPlaceLabel:(UILabel *)placeLabel{
    objc_setAssociatedObject(self, @selector(placeLabel), placeLabel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - swizzled
-(instancetype)placeHolder_initWithFrame:(CGRect)frame{
    if ([self placeHolder_initWithFrame:frame]) {
        [self preparePlaceLabel];
    }
    return self;
}

- (void)placeHolder_layoutSubviews {
    [self placeHolder_layoutSubviews];

    if (self.placeholder.length) {
        UIEdgeInsets textContainerInset =  self.textContainerInset;
        CGFloat lineFragmentPadding = self.textContainer.lineFragmentPadding;
        CGFloat x = lineFragmentPadding + textContainerInset.left + self.layer.borderWidth;
        CGFloat y = textContainerInset.top + self.layer.borderWidth;
        CGFloat width = CGRectGetWidth(self.bounds) - x - textContainerInset.right - 2*self.layer.borderWidth;
        CGFloat height = [self.placeLabel sizeThatFits:CGSizeMake(width, 0)].height;
        self.placeLabel.frame = CGRectMake(x, y, width, height);
    }
}

-(void)placeHolder_setFont:(UIFont *)font{
    [self placeHolder_setFont:font];
    self.placeLabel.font = self.font;
}

-(void)placeHolder_setTextAlignment:(NSTextAlignment *)textAlignment{
    [self placeHolder_setTextAlignment:textAlignment];
    self.placeLabel.textAlignment = self.textAlignment;
}

#pragma mark - private method
/// 预置placeLabel
-(void)preparePlaceLabel{
    self.placeLabel = [[UILabel alloc]init];
    self.placeLabel.backgroundColor = [UIColor clearColor];
    self.placeLabel.textColor = [UIColor systemGrayColor];
}


/// 添加通知
-(void)addNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePlaceLabel:) name:UITextViewTextDidBeginEditingNotification object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePlaceLabel:) name:UITextViewTextDidEndEditingNotification object:self];
}


/// 更新PlaceLabel
/// @param notif <#notif description#>
- (void)updatePlaceLabel:(NSNotification *)notif{
    if ([notif.name isEqualToString:UITextViewTextDidEndEditingNotification]) {
        if (self.text.length) {
            [self.placeLabel removeFromSuperview];
        }
        else{
            if (![self.placeLabel isDescendantOfView:self] && self.placeholder.length) {
                [self insertSubview:self.placeLabel atIndex:0];
            }
        }
    }
    else{
        [self.placeLabel removeFromSuperview];
    }
}

#pragma mark - dealloc
- (void)dealloc {
    @try {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidBeginEditingNotification object:self];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidEndEditingNotification object:self];
    } @catch (NSException *exception) {
        NSLog(@"exception:%@",exception.description);
    } @finally {
    }
}

@end
