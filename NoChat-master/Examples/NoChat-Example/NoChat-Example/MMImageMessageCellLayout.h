//
//  MMImageMessageCellLayout.h
//  NoChat-Example
//
//  Created by iOS Developer on 2019/6/27.
//  Copyright © 2019 little2s. All rights reserved.
//

#import "MMBaseMessageCellLayout.h"

NS_ASSUME_NONNULL_BEGIN

@interface MMImageMessageCellLayout : MMBaseMessageCellLayout
@property (nonatomic, assign) CGRect imageViewFrame;
@property (nonatomic, strong) CAShapeLayer *maskLayer;
@end

NS_ASSUME_NONNULL_END
