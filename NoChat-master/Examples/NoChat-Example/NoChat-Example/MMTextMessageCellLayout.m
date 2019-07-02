//
//  MMTextMessageCellLayout.m
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

#import "MMTextMessageCellLayout.h"
#import "NOCMessage.h"
#import "YYImage.h"

@implementation MMTextMessageCellLayout {
    NSMutableAttributedString *_attributedText;
}

- (instancetype)initWithChatItem:(id<NOCChatItem>)chatItem cellWidth:(CGFloat)width
{
    self = [super initWithChatItem:chatItem cellWidth:width];
    if (self) {
        self.reuseIdentifier = @"MMTextMessageCell";
        [self setupAttributedText];
        [self setupBubbleImage];
        [self calculateLayout];
    }
    return self;
}

- (void)setupAttributedText
{
    NSString *text = self.message.text;
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:text attributes:@{ NSFontAttributeName: [MMTextMessageCellLayout textFont], NSForegroundColorAttributeName: [MMTextMessageCellLayout textColor] }];
    NSString *regulaStr = @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
    NSString *regEmj  = @"\\[[a-zA-Z0-9\\/\\u4e00-\\u9fa5]+\\]";
    NSError *error = nil;
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:regEmj
                                                                                options:NSRegularExpressionCaseInsensitive
                                                                                  error:&error];
    if (!expression) {
        NSLog(@"正则创建失败error！= %@", [error localizedDescription]);
    } else {
        NSArray *allMatches = [expression matchesInString:attrString.string options:NSMatchingReportCompletion range:NSMakeRange(0, attrString.string.length)];
        NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:allMatches.count];
//        for (NSTextCheckingResult *match in allMatches) {
//            NSRange range    = match.range;
//            NSString *subStr = [text substringWithRange:range];
//            for (NSString *face in @[@"[NO]"]) {
//                if ([face isEqualToString:subStr]) {
//                    UIImage *image = [UIImage imageNamed:face];//修改表情大小
//                    YYAnimatedImageView *imageView = [[YYAnimatedImageView alloc] initWithImage:image];
//                    NSMutableAttributedString *attachText = [NSMutableAttributedString yy_attachmentStringWithContent:imageView contentMode:UIViewContentModeCenter attachmentSize:imageView.frame.size alignToFont:attrString.yy_font alignment:YYTextVerticalAlignmentCenter];
//                    [attrString replaceCharactersInRange:match.range withAttributedString:attachText];
//                }
//            }
//        }
        for (NSTextCheckingResult *match in allMatches) {
            NSRange range    = match.range;
            NSString *subStr = [text substringWithRange:range];
            for (NSString *face in @[@"[NO]"]) {
                if ([face isEqualToString:subStr]) {
                    UIImage *image = [UIImage imageNamed:face];//修改表情大小
                    YYAnimatedImageView *imageView = [[YYAnimatedImageView alloc] initWithImage:image];
                    NSMutableAttributedString *attachText = [NSMutableAttributedString yy_attachmentStringWithContent:imageView contentMode:UIViewContentModeCenter attachmentSize:imageView.frame.size alignToFont:attrString.yy_font alignment:YYTextVerticalAlignmentCenter];
                    NSMutableDictionary *imagDic   = [NSMutableDictionary dictionaryWithCapacity:2];
                    [imagDic setObject:attachText forKey:@"image"];
                    [imagDic setObject:[NSValue valueWithRange:range] forKey:@"range"];
                    [mutableArray addObject:imagDic];
                }
            }
        }
        for (int i =(int) mutableArray.count - 1; i >= 0; i --) {
            NSRange range;
            [mutableArray[i][@"range"] getValue:&range];
            [attrString replaceCharactersInRange:range withAttributedString:mutableArray[i][@"image"]];
        }
    }
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];

    
    if (!regex) {
        
    } else {
        NSArray *allMatches = [regex matchesInString:attrString.string options:NSMatchingReportCompletion range:NSMakeRange(0, attrString.string.length)];
        for (NSTextCheckingResult *match in allMatches) {
            
            NSString *substrinsgForMatch = [attrString.string substringWithRange:match.range];
            NSMutableAttributedString *one = [[NSMutableAttributedString alloc] initWithString:substrinsgForMatch];
            one.yy_underlineStyle = NSUnderlineStyleSingle;
            one.yy_color = [UIColor colorWithRed:0.093 green:0.492 blue:1.000 alpha:1.000];
            
            YYTextBorder *border = [YYTextBorder new];
            border.cornerRadius = 3;
            border.insets = UIEdgeInsetsMake(-2, -1, -2, -1);
            border.fillColor = [UIColor colorWithWhite:0.000 alpha:0.220];
            
            YYTextHighlight *highlight = [YYTextHighlight new];
            [highlight setBorder:border];
            [one yy_setTextHighlight:highlight range:one.yy_rangeOfAll];
            highlight.userInfo = @{@"linkUrl":substrinsgForMatch};
            [attrString replaceCharactersInRange:match.range withAttributedString:one];
        }
    }
    
    _attributedText = attrString;
}

- (void)setupBubbleImage
{
    _bubbleImage = self.isOutgoing ? [MMTextMessageCellLayout outgoingBubbleImage] : [MMTextMessageCellLayout incomingBubbleImage];
    _highlightBubbleImage = self.isOutgoing ?[MMTextMessageCellLayout highlightOutgoingBubbleImage] : [MMTextMessageCellLayout highlightIncomingBubbleImage];
}

- (void)calculateLayout
{
    [super calculateLayout];
    
    self.height = 0;
    self.bubbleViewFrame = CGRectZero;
    self.bubbleImageViewFrame = CGRectZero;
    self.textLabelFrame = CGRectZero;
    self.textLayout = nil;
    
    NSMutableAttributedString *text = _attributedText;
    if (text.length == 0) {
        return;
    }
    
    // dynamic font support
    [text yy_setAttribute:NSFontAttributeName value:[MMTextMessageCellLayout textFont]];
    
    BOOL isOutgoing = self.isOutgoing;
    UIEdgeInsets bubbleMargin = self.bubbleViewMargin;
    CGFloat bubbleViewWidth = [self prefrredMaxBubbleWidth];
    
    UIEdgeInsets textMargin = isOutgoing ? UIEdgeInsetsMake(10, 10, 10, 15) : UIEdgeInsetsMake(10, 15, 10, 10);
    CGFloat textLabelWidth = bubbleViewWidth - textMargin.left - textMargin.right;
    
    MMTextLinePositionModifier *modifier = [[MMTextLinePositionModifier alloc] init];
    modifier.font = [MMTextMessageCellLayout textFont];
    modifier.paddingTop = 2;
    modifier.paddingBottom = 2;
    
    YYTextContainer *container = [[YYTextContainer alloc] init];
    container.size = CGSizeMake(textLabelWidth, CGFLOAT_MAX);
    container.linePositionModifier = modifier;
    
    self.textLayout = [YYTextLayout layoutWithContainer:container text:text];
    if (!self.textLayout) {
        return;
    }
    
    textLabelWidth = ceil(self.textLayout.textBoundingSize.width);
    CGFloat textLabelHeight = ceil([modifier heightForLineCount:self.textLayout.rowCount]);
    self.textLabelFrame = CGRectMake(textMargin.left, textMargin.top, textLabelWidth, textLabelHeight);
    
    bubbleViewWidth = textLabelWidth + textMargin.left + textMargin.right;
    CGFloat bubbleViewHeight = textLabelHeight + textMargin.top + textMargin.bottom;
    CGFloat bubbleViewTop = bubbleMargin.top + CGRectGetMaxY(self.nicknameViewFrame) + self.nicknameViewMargin.bottom;
    if (isOutgoing) {
        self.bubbleViewFrame = CGRectMake(self.width - bubbleMargin.right - bubbleViewWidth,
                                          bubbleViewTop,
                                          bubbleViewWidth,
                                          bubbleViewHeight);
    } else {
        self.bubbleViewFrame = CGRectMake(bubbleMargin.left,
                                          bubbleViewTop,
                                          bubbleViewWidth,
                                          bubbleViewHeight);
    }
    self.bubbleImageViewFrame = CGRectMake(0, 0, bubbleViewWidth, bubbleViewHeight);
    
    self.height = bubbleViewHeight + bubbleViewTop + bubbleMargin.bottom;
}

@end

@implementation MMTextMessageCellLayout (MMStyle)

+ (UIImage *)outgoingBubbleImage
{
    static UIImage *_outgoingBubbleImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _outgoingBubbleImage = [UIImage imageNamed:@"TGBubbleOutgoingPartial"];
    });
    return _outgoingBubbleImage;
}

+ (UIImage *)highlightOutgoingBubbleImage
{
    static UIImage *_highlightOutgoingBubbleImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _highlightOutgoingBubbleImage = [UIImage imageNamed:@"TGBubbleOutgoingPartialHL"];
    });
    return _highlightOutgoingBubbleImage;
}

+ (UIImage *)incomingBubbleImage
{
    static UIImage *_incomingBubbleImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _incomingBubbleImage = [UIImage imageNamed:@"TGBubbleIncomingPartial"];
    });
    return _incomingBubbleImage;
}

+ (UIImage *)highlightIncomingBubbleImage
{
    static UIImage *_highlightIncomingBubbleImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _highlightIncomingBubbleImage = [UIImage imageNamed:@"TGBubbleIncomingPartialHL"];
    });
    return _highlightIncomingBubbleImage;
}

+ (UIFont *)textFont
{
    return [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
}

+ (UIColor *)textColor
{
    return [UIColor blackColor];
}

+ (UIColor *)linkColor
{
    static UIColor *_linkColor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _linkColor = [UIColor colorWithRed:31/255.0 green:121/255.0 blue:253/255.0 alpha:1];
    });
    return _linkColor;
}

+ (UIColor *)linkBackgroundColor
{
    static UIColor *_linkBackgroundColor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _linkBackgroundColor = [UIColor colorWithRed:212/255.0 green:209/255.0 blue:209/255.0 alpha:1];
    });
    return _linkBackgroundColor;
}

@end

@implementation MMTextLinePositionModifier

- (instancetype)init
{
    self = [super init];
    if ([NSProcessInfo.processInfo isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion){9,0,0}]) {
        _lineHeightMultiple = 1.34;   // for PingFang SC
    } else {
        _lineHeightMultiple = 1.3125; // for Heiti SC
    }
    return self;
}

- (void)modifyLines:(NSArray *)lines fromText:(NSAttributedString *)text inContainer:(YYTextContainer *)container
{
    CGFloat ascent = _font.pointSize * 0.86;
    
    CGFloat lineHeight = _font.pointSize * _lineHeightMultiple;
    for (YYTextLine *line in lines) {
        CGPoint position = line.position;
        position.y = _paddingTop + ascent + line.row  * lineHeight;
        line.position = position;
    }
}

- (id)copyWithZone:(NSZone *)zone
{
    MMTextLinePositionModifier *one = [self.class new];
    one->_font = _font;
    one->_paddingTop = _paddingTop;
    one->_paddingBottom = _paddingBottom;
    one->_lineHeightMultiple = _lineHeightMultiple;
    return one;
}

- (CGFloat)heightForLineCount:(NSUInteger)lineCount
{
    if (lineCount == 0) return 0;
    CGFloat ascent = _font.pointSize * 0.86;
    CGFloat descent = _font.pointSize * 0.14;
    CGFloat lineHeight = _font.pointSize * _lineHeightMultiple;
    return _paddingTop + _paddingBottom + ascent + descent + (lineCount - 1) * lineHeight;
}

@end

