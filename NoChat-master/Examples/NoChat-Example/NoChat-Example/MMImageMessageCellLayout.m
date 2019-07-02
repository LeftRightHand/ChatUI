//
//  MMImageMessageCellLayout.m
//  NoChat-Example
//
//  Created by iOS Developer on 2019/6/27.
//  Copyright © 2019 little2s. All rights reserved.
//

#import "MMImageMessageCellLayout.h"
#import "NOCImageMessage.h"

@implementation MMImageMessageCellLayout


- (instancetype)initWithChatItem:(id<NOCChatItem>)chatItem cellWidth:(CGFloat)width
{
    self = [super initWithChatItem:chatItem cellWidth:width];
    if (self) {
        self.reuseIdentifier = @"MMImageMessageCell";
        [self calculateLayout];
    }
    return self;
}

- (CGSize)displaySizeForImageSourceSize:(CGSize)sourceSize {
    CGFloat realWidth = sourceSize.width;
    CGFloat realHeight = sourceSize.height;
    CGFloat imageMaxSize = [self prefrredMaxBubbleWidth];
    if (sourceSize.width > sourceSize.height) {
        if (sourceSize.width > imageMaxSize) {
            realWidth = imageMaxSize;
            realHeight =  sourceSize.height * imageMaxSize / sourceSize.width;
        }
    } else {
        if (sourceSize.height > imageMaxSize) {
            realHeight = imageMaxSize;
            realWidth = sourceSize.width * imageMaxSize / sourceSize.height;
        }
    }
    return CGSizeMake(realWidth, realHeight);
}

- (CGFloat)prefrredMaxBubbleWidth {
    return ceil(self.width * 0.48);
}

- (void)calculateLayout {
    [super calculateLayout];
    
    self.height = 0;
    self.bubbleViewFrame = CGRectZero;
    
    UIImage *image = [(NOCImageMessage *)self.message image];
    UIEdgeInsets bubbleMargin = self.bubbleViewMargin;
    CGFloat bubbleViewWidth = [self prefrredMaxBubbleWidth];
    CGFloat bubbleViewTop = bubbleMargin.top + CGRectGetMaxY(self.nicknameViewFrame) + self.nicknameViewMargin.bottom;
    CGFloat bubbleViewHeight = bubbleViewWidth;
    
    if (image) {
        CGSize imageSize = [self displaySizeForImageSourceSize:image.size];
        bubbleViewWidth = imageSize.width;
        bubbleViewHeight = imageSize.height;
        NSLog(@"image width:%f height:%f", bubbleViewWidth, bubbleViewHeight);
    }
    
    UIEdgeInsets imageMargin = UIEdgeInsetsMake(0, 10, 0, 0);
    
    if (self.isOutgoing) {
        self.bubbleViewFrame = CGRectMake(self.width - bubbleMargin.right - bubbleViewWidth - imageMargin.left,
                                          bubbleViewTop,
                                          bubbleViewWidth,
                                          bubbleViewHeight);
    } else {
        self.bubbleViewFrame = CGRectMake(bubbleMargin.left + imageMargin.left,
                                          bubbleViewTop,
                                          bubbleViewWidth,
                                          bubbleViewHeight);
    }
    self.imageViewFrame = CGRectMake(0,
                                     0,
                                     bubbleViewWidth,
                                     bubbleViewHeight);
    
    CGRect imageViewRoundedRect = CGRectZero;
    imageViewRoundedRect.size = self.imageViewFrame.size;
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:imageViewRoundedRect
                                                        cornerRadius:5];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc]init];
    maskLayer.frame = imageViewRoundedRect;
    maskLayer.path = maskPath.CGPath;
    self.maskLayer = maskLayer;
    
    self.height = bubbleViewHeight + bubbleViewTop + bubbleMargin.bottom;
}

@end
