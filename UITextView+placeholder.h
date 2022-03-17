//
//  UITextView+placeholder.h
//
//  Created by 陈振奎 on 2022/3/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITextView (placeholder)

/**
 *  IQKeyboardManager等第三方框架会读取placeholder属性并创建UIToolbar展示,所以此属性一定要赋值
 */
@property (nonatomic, copy) NSString *placeholder;

//其余扩展属性，请操作placeLabel
@property (nonatomic, strong) UILabel *placeLabel;

@end

NS_ASSUME_NONNULL_END
