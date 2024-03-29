//
//  MMBaseMessageCellLayout.h
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

#import <NoChat/NoChat.h>

@class NOCMessage;

@interface MMBaseMessageCellLayout : NSObject <NOCChatItemCellLayout>

@property (nonatomic, strong) NSString *reuseIdentifier;
@property (nonatomic, strong) id<NOCChatItem> chatItem;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, strong) NOCMessage *message;

@property (nonatomic, assign, readonly) BOOL isOutgoing;
@property (nonatomic, assign, readonly) BOOL isDisplayNickname;
@property (nonatomic, assign, readonly) BOOL isActivityIndicatorHidden;

@property (nonatomic, assign) UIEdgeInsets bubbleViewMargin;
@property (nonatomic, assign) UIEdgeInsets nicknameViewMargin;
@property (nonatomic, assign) CGPoint nicknameOrigin;
@property (nonatomic, assign) CGSize nicknameSize;
@property (nonatomic, assign) CGRect nicknameViewFrame;
@property (nonatomic, assign) CGRect bubbleViewFrame;
@property (nonatomic, assign) CGFloat avatarSize;
@property (nonatomic, assign) CGRect avatarImageViewFrame;
@property (nonatomic, strong) CAShapeLayer *avatarMaskLayer;
@property (nonatomic, strong) UIImage *avatarImage;

- (instancetype)initWithChatItem:(id<NOCChatItem>)chatItem cellWidth:(CGFloat)width;
- (void)calculateLayout;
- (CGFloat)prefrredMaxBubbleWidth;
@end

@interface MMBaseMessageCellLayout (MMStyle)

+ (UIImage *)outgoingAvatarImage;
+ (UIImage *)incomingAvatarImage;

@end
