//
//  MMBaseMessageCellLayout.m
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

#import "MMBaseMessageCellLayout.h"
#import "NOCMessage.h"

#define CellBubbleViewInsetsLeft 52
#define CellBubbleViewInsetsRight 52
#define CellBubbleViewInsetsTop 0
#define CellBubbleViewInsetsBottom 8
#define CellNicknameHeight 25
#define CellAvatarSize 40
#define CellMargin 8

@implementation MMBaseMessageCellLayout

- (instancetype)initWithChatItem:(id<NOCChatItem>)chatItem cellWidth:(CGFloat)width
{
    self = [super init];
    if (self) {
        _reuseIdentifier = @"MMBaseMessageCell";
        _chatItem = chatItem;
        _width = width;
        _bubbleViewMargin = UIEdgeInsetsMake(CellBubbleViewInsetsTop,
                                             CellBubbleViewInsetsLeft,
                                             CellBubbleViewInsetsBottom,
                                             CellBubbleViewInsetsRight);
        _avatarSize = CellAvatarSize;
        _nicknameSize.height = self.isDisplayNickname ? CellNicknameHeight : 0;
        _nicknameSize.width = self.isDisplayNickname ? width - CellMargin * 2 : 0;
        _avatarImage = self.isOutgoing ? [MMBaseMessageCellLayout outgoingAvatarImage] : [MMBaseMessageCellLayout incomingAvatarImage];
    }
    return self;
}

- (void)calculateLayout
{
    CGFloat avatarWidth = self.avatarSize;
    CGFloat avatarHeight = self.avatarSize;
    self.nicknameViewFrame = self.isDisplayNickname ? CGRectMake(CellMargin, CellMargin, self.nicknameSize.width, self.nicknameSize.height) : CGRectMake(0, 0, self.nicknameSize.width, self.nicknameSize.height);
    CGFloat avatarY = self.isDisplayNickname ? CGRectGetMaxY(self.nicknameViewFrame) : 0;
    self.avatarImageViewFrame = self.isOutgoing ? CGRectMake(self.width - CellMargin - avatarWidth, avatarY, avatarWidth, avatarHeight) : CGRectMake(CellMargin, avatarY, avatarWidth, avatarHeight);
}

- (NOCMessage *)message
{
    return (NOCMessage *)self.chatItem;
}

- (BOOL)isOutgoing
{
    return self.message.isOutgoing;
}
    
- (BOOL)isDisplayNickname {
    return self.message.isDisplayNickname;
}

- (BOOL)isActivityIndicatorHidden
{
    if (self.message.isOutgoing) {
        switch (self.message.deliveryStatus) {
            case NOCMessageDeliveryStatusDelivering:
                return NO;
                break;
            default:
                return YES;
                break;
        }
    }
    return YES;
}

@end

@implementation MMBaseMessageCellLayout (MMStyle)

+ (UIImage *)outgoingAvatarImage
{
    static UIImage *_outgoingAvatarImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _outgoingAvatarImage = [UIImage imageNamed:@"MMAvatarOutgoing"];
    });
    return _outgoingAvatarImage;
}

+ (UIImage *)incomingAvatarImage
{
    static UIImage *_incomingAvatarImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _incomingAvatarImage = [UIImage imageNamed:@"MMAvatarIncoming"];
    });
    return _incomingAvatarImage;
}

@end
