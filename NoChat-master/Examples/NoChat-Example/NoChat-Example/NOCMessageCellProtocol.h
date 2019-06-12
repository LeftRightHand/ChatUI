//
//  NOCMessageCellProtocol.h
//  NIMKit
//
//  Created by NetEase.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NOCMessage;

@protocol NOCMessageCellDelegate <NSObject>

@optional
    
- (BOOL)disableAudioPlayedStatusIcon:(NOCMessage *)message;

#pragma mark - 点击事件
- (BOOL)onTapCell:(NOCMessage *)event;

- (BOOL)onLongPressCell:(NOCMessage *)message
                 inView:(UIView *)view;

- (BOOL)onTapAvatar:(NOCMessage *)message;

- (BOOL)onLongPressAvatar:(NOCMessage *)message;

- (BOOL)onPressReadLabel:(NOCMessage *)message;

- (void)onRetryMessage:(NOCMessage *)message;


@end
