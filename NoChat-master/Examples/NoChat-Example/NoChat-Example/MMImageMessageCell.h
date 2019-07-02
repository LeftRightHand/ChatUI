//
//  MMImageMessageCell.h
//  NoChat-Example
//
//  Created by iOS Developer on 2019/6/27.
//  Copyright © 2019 little2s. All rights reserved.
//

#import "MMBaseMessageCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface MMImageMessageCell : MMBaseMessageCell {
    UILongPressGestureRecognizer *_longPressGesture;
}
@property (nonatomic, strong) UIImageView *imageView;
@end

NS_ASSUME_NONNULL_END
