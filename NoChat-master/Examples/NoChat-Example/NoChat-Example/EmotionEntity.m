//
//  EmotionEntity.m
//  ComChat
//
//  Created by D404 on 15/6/9.
//  Copyright (c) 2015年 D404. All rights reserved.
//

#import "EmotionEntity.h"

@implementation EmotionEntity

- (BOOL)isEqual:(EmotionEntity *)emotion
{
    return [self.face_name isEqualToString:emotion.face_name] || [self.code isEqualToString:emotion.code];
}

@end
