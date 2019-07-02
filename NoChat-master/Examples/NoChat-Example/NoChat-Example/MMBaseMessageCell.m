//
//  MMBaseMessageCell.m
//  NoChat-Example
//
//  Copyright (c) 2016-present, little2s.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import "MMBaseMessageCell.h"
#import "MMBaseMessageCellLayout.h"

#import "NOCMessage.h"

@implementation MMBaseMessageCell

@synthesize indexPath = _indexPath;

+ (NSString *)reuseIdentifier
{
    return @"MMBaseMessageCell";
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _avatarImageView = [[UIImageView alloc] init];
        [self.itemView addSubview:_avatarImageView];
        
        _bubbleView = [[UIView alloc] init];
        [self.itemView addSubview:_bubbleView];
        
        _nickNameLabel = [[UILabel alloc] init];
        _nickNameLabel.font = [UIFont systemFontOfSize:13];
        _nickNameLabel.textColor = [UIColor darkGrayColor];
        [self.itemView addSubview:_nickNameLabel];
        
        _traningActivityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0,0,20,20)];
        _traningActivityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [self.itemView addSubview:_traningActivityIndicator];
    }
    return self;
}

- (void)setCellForItemAtIndexPath:(NSIndexPath *)indexPath {
    _indexPath = indexPath;
}

- (void)setLayout:(id<NOCChatItemCellLayout>)layout
{
    [super setLayout:layout];
    
    MMBaseMessageCellLayout *cellLayout = (MMBaseMessageCellLayout *)layout;
    self.nickNameLabel.frame = cellLayout.nicknameViewFrame;
    self.bubbleView.frame = cellLayout.bubbleViewFrame;
    self.avatarImageView.frame = cellLayout.avatarImageViewFrame;
    self.avatarImageView.image = cellLayout.avatarImage;
    self.avatarImageView.layer.mask = cellLayout.avatarMaskLayer;
    
    if (cellLayout.isActivityIndicatorHidden) {
        [self.traningActivityIndicator stopAnimating];
    } else {
        [self.traningActivityIndicator startAnimating];
    }
    
    [self setLayoutActivityIndicator];
    
    self.message = cellLayout.message;
    
    if (cellLayout.isDisplayNickname) {
        self.nickNameLabel.text = cellLayout.message.nickname;
        self.nickNameLabel.textAlignment = cellLayout.isOutgoing ? NSTextAlignmentRight : NSTextAlignmentLeft;
    }
    
}

- (void)setupActivityIndicatorHidden {
    [self.traningActivityIndicator stopAnimating];
}

- (void)setLayoutActivityIndicator
{
    if (self.traningActivityIndicator.isAnimating) {
        CGFloat centerX = CGRectGetMinX(self.bubbleView.frame) - CGRectGetWidth(self.traningActivityIndicator.bounds)/2 - 6;
        self.traningActivityIndicator.center = CGPointMake(centerX,
                                                           self.bubbleView.center.y);
    }
}

@end
