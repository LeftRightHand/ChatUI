//
//  MMImageMessageCell.m
//  NoChat-Example
//
//  Created by iOS Developer on 2019/6/27.
//  Copyright © 2019 little2s. All rights reserved.
//

#import "MMImageMessageCell.h"
#import "MMImageMessageCellLayout.h"

#import "NOCImageMessage.h"

@implementation MMImageMessageCell

+ (NSString *)reuseIdentifier
{
    return @"MMImageMessageCell";
}


- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupSubview];
    }
    return self;
}

- (void)setupSubview {
    _imageView = [[UIImageView alloc] init];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.bubbleView addSubview:_imageView];
    
    _longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGesturePress:)];
    [self.bubbleView addGestureRecognizer:_longPressGesture];
}

- (void)setLayout:(id<NOCChatItemCellLayout>)layout {
    [super setLayout:layout];
    
    MMImageMessageCellLayout *cellLayout = (MMImageMessageCellLayout *)layout;
    self.imageView.frame = cellLayout.imageViewFrame;
    self.imageView.layer.mask = cellLayout.maskLayer;
    
    NOCImageMessage *message = (NOCImageMessage *)cellLayout.message;
    if (message.image) {
        self.imageView.image = message.image;
    } else {
        self.imageView.image = nil;
    }
}

- (void)setLayoutActivityIndicator {
    if (self.traningActivityIndicator.isAnimating) {
//        CGFloat centerX = CGRectGetMinX(self.bubbleView.frame)  - CGRectGetWidth(self.traningActivityIndicator.bounds)/2;
        self.traningActivityIndicator.center = self.bubbleView.center;
    }
}

#pragma mark - Action
- (void)longGesturePress:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]] &&
        gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(onLongPressCell:inView:)]) {
            [self.delegate onLongPressCell:self.message
                                    inView:self.bubbleView];
        }
    }
}

@end
