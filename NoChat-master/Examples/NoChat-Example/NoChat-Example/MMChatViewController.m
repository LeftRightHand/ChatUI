//
//  MMChatViewController.m
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
#import "MMChatViewController.h"

#import "MMBaseMessageCellLayout.h"
#import "MMTextMessageCell.h"
#import "MMTextMessageCellLayout.h"
#import "MMDateMessageCell.h"
#import "MMDateMessageCellLayout.h"
#import "MMSystemMessageCell.h"
#import "MMSystemMessageCellLayout.h"
#import "MMImageMessageCell.h"
#import "MMImageMessageCellLayout.h"

#import "MMChatInputTextPanel.h"

#import "NOCUser.h"
#import "NOCChat.h"
#import "NOCMessage.h"
#import "NOCImageMessage.h"

#import "NOCMessageManager.h"

#import "NOCProtoKit.h"

@interface MMChatViewController ()
    <UINavigationControllerDelegate,
    NOCMessageManagerDelegate,
    NOCClientDelegate,
    NOCMessageCellDelegate>

@property (nonatomic, strong) NOCMessageManager *messageManager;
@property (nonatomic, strong) dispatch_queue_t layoutQueue;

@property (nonatomic, strong) NSTimer * timer;

@end

@implementation MMChatViewController

#pragma mark - Overrides

+ (Class)cellLayoutClassForItemType:(NSString *)type
{
    if ([type isEqualToString:@"Text"]) {
        return [MMTextMessageCellLayout class];
    } else if ([type isEqualToString:@"Date"]) {
        return [MMDateMessageCellLayout class];
    } else if ([type isEqualToString:@"System"]) {
        return [MMSystemMessageCellLayout class];
    } else if ([type isEqualToString:@"Image"]) {
        return [MMImageMessageCellLayout class];
    } else {
        return nil;
    }
}

+ (Class)inputPanelClass
{
    return [MMChatInputTextPanel class];
}

- (void)registerChatItemCells
{
    [self.collectionView registerClass:[MMImageMessageCell class]
            forCellWithReuseIdentifier:[MMImageMessageCell reuseIdentifier]];
    [self.collectionView registerClass:[MMTextMessageCell class]
            forCellWithReuseIdentifier:[MMTextMessageCell reuseIdentifier]];
    [self.collectionView registerClass:[MMDateMessageCell class]
            forCellWithReuseIdentifier:[MMDateMessageCell reuseIdentifier]];
    [self.collectionView registerClass:[MMSystemMessageCell class]
            forCellWithReuseIdentifier:[MMSystemMessageCell reuseIdentifier]];
}

- (instancetype)initWithChat:(NOCChat *)chat
{
    self = [super init];
    if (self) {
        self.chat = chat;
        self.messageManager = [NOCMessageManager manager];
        [self.messageManager addDelegate:self];
        self.inverted = NO;
        self.isShowBottomNews = YES;
        self.chatInputContainerViewDefaultHeight = 50;
        dispatch_queue_attr_t attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_DEFAULT, 0);
        _layoutQueue = dispatch_queue_create("com.little2s.nochat-example.mm.layout", attr);
        
        MMChatInputTextPanel * chatInput = [[MMChatInputTextPanel alloc] init];
        self.safeAreaInsetsBottomView = chatInput.backgroundView;
    }
    return self;
}

- (void)dealloc
{
    [self.messageManager removeDelegate:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.backgroundView.image = [UIImage imageNamed:@"TGWallpaper"];
    self.navigationController.delegate = self;
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"MMUserInfo"] style:UIBarButtonItemStylePlain target:self action:@selector(onPlay)];
    self.navigationItem.rightBarButtonItem = rightItem;
    self.title = self.chat.title;
    
    [self loadMessages];
    
    
}

- (void)onPlay {
    [self receiveMessage];
}

- (void)beginChange {
    [self receiveMessage];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithWhite:0.1 alpha:0.9];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.barTintColor = nil;
    self.navigationController.navigationBar.tintColor = nil;
    [self.timer invalidate];
    self.timer = nil;
    [super viewWillDisappear:animated];
}

#pragma mark - 菜单
- (NSArray *)menusItems:(NOCMessage *)message
{
    NSMutableArray *items = [NSMutableArray array];
    [items addObject:[[UIMenuItem alloc] initWithTitle:@"复制"
                                                    action:@selector(copyText:)]];
    [items addObject:[[UIMenuItem alloc] initWithTitle:@"删除"
                                                action:@selector(deleteMsg:)]];
    return items;
    
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)copyText:(id)sender
{
  
}

- (void)deleteMsg:(id)sender
{
  
}

- (void)chatItemCell:(NOCChatItemCell *)cell cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if ([cell isKindOfClass:MMBaseMessageCell.class]) {
        [(MMBaseMessageCell *)cell setDelegate:self];
        [(MMBaseMessageCell *)cell setCellForItemAtIndexPath:indexPath];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.collectionView && scrollView.isTracking) {
        [self.inputPanel endInputting:YES];
    }
}

#pragma mark - MMChatInputTextPanelDelegate

- (void)didInputTextPanelStartInputting:(MMChatInputTextPanel *)inputTextPanel
{
    if (![self isScrolledAtBottom]) {
        [self scrollToBottomAnimated:YES];
    }
}

- (void)inputTextPanel:(MMChatInputTextPanel *)inputTextPanel requestSendText:(NSString *)text
{
    NOCMessage *message = [[NOCMessage alloc] init];
    message.text = text;
    [self sendMessage:message];
}

#pragma mark - MMTextMessageCellDelegate

- (void)cell:(MMTextMessageCell *)cell didTapLink:(NSDictionary *)linkInfo
{
    [self.inputPanel endInputting:YES];
    
    NSString *command = linkInfo[@"linkUrl"];
    if (!command) {
        return;
    }
    
    NOCMessage *message = [[NOCMessage alloc] init];
    message.text = command;
    [self sendMessage:message];
}

- (BOOL)onLongPressCell:(id<NOCChatItem>)message inView:(UIView *)view {
    NSLog(@"%@", [(NOCMessage *)message msgId]);
    BOOL handle = NO;
    NSArray *items = [self menusItems:message];
    if ([items count] && [self becomeFirstResponder]) {
        UIMenuController *controller = [UIMenuController sharedMenuController];
        controller.menuItems = items;
        [controller setTargetRect:view.bounds inView:view];
        [controller setMenuVisible:YES animated:YES];
        handle = YES;
    }
    return handle;
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (![viewController isKindOfClass:NSClassFromString(@"NOCChatsViewController")]) {
        return;
    }
    
    self.isInControllerTransition = YES;
    
    __weak typeof(self) weakSelf = self;
    id<UIViewControllerTransitionCoordinator> transitionCoordinator = navigationController.topViewController.transitionCoordinator;
    [transitionCoordinator notifyWhenInteractionEndsUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        if ([context isCancelled] && weakSelf) {
            weakSelf.isInControllerTransition = NO;
        }
    }];
}

#pragma mark - NOCMessageManagerDelegate

- (void)didReceiveMessages:(NSArray *)messages chatId:(NSString *)chatId
{
    if (!self.isViewLoaded) {
        return;
    }
    
    if ([chatId isEqualToString:self.chat.chatId]) {
        [self addMessages:messages scrollToBottom:YES animated:YES];
    }
}

- (void)deliveredMessage:(NSArray *)messages {
    NSLog(@"%ld", messages.count);
    for (NOCMessage *message in messages) {
        [self findMessage:message];
    }
}

#pragma mark - Private

- (void)loadMessages
{
    [self.layouts removeAllObjects];
    
    __weak typeof(self) weakSelf = self;
    [self.messageManager fetchMessagesWithChatId:self.chat.chatId handler:^(NSArray *messages) {
        if (weakSelf) {
            [weakSelf addMessages:messages scrollToBottom:YES animated:NO];
        }
    }];
    
    
}

- (void)sendMessage:(NOCMessage *)message
{
    message.senderId = [NOCUser currentUser].userId;
    message.date = [NSDate date];
    message.deliveryStatus = NOCMessageDeliveryStatusDelivering;
    message.outgoing = YES;
    
    [self addMessages:@[message] scrollToBottom:YES animated:YES];
    
    [self.messageManager sendMessage:message toChat:self.chat];
}

- (void)receiveMessage {
    NSArray *msgs = @[
                      @"[NO][NO][NO][NO][NO][NO][NO][NO][NO][NO][NO]",
                      @"Lucky for you they made you learn Gothon insults in the academy.[NO][NO][NO]",
                      @"You tell the one Gothon joke you know: Lbhe zbgure vf fb sng, jura fur fvgf nebhaq gur ubhfr, fur fvgf nebhaq gur ubhfr.",
                      @"The Gothon stops, tries not to laugh,[NO][NO]then busts out laughing and can't move.",
                      @"While he's laughing you run up and shoot him square in the head putting him down, then jump through the Weapon Armory door.",
                      @"Quick on the draw you yank out your blaster and fire it at the Gothon.",
                      @"His clown costume is flowing and moving around his body, which throws off your aim.",
                      @"Your laser hits his costume but misses him entirely.",
                      @"This makes him fly into a rage and blast you repeatedly in the face until you are dead.",
                      @"Then he eats you.",
                      @"Like a world class boxer you dodge, weave, slip and slide right, as the Gothon's blaster cranks a laser past your head.",
                      @"In the middle of your artful dodge your foot slips and you bang your head on the metal wall and pass out.",
                      @"You wake up shortly after only to die as the Gothon stomps on your head and eats you."
                      ];
    int count = (int)msgs.count;
    NSUInteger num = arc4random_uniform(count);
    NSMutableArray *messages = [NSMutableArray array];
    for (NSUInteger i = 0; i < num; i++) {
        
        int i = arc4random() % 2;
        int text = arc4random() % 2;
        int img = arc4random() % 2;
        int j = arc4random() % 2;
        
        if (text) {
            NOCMessage *message = [[NOCMessage alloc] init];
            message.text = msgs[i];
            message.senderId = @"3330";
            message.deliveryStatus = NOCMessageDeliveryStatusRead;
            message.outgoing = i ? YES : NO;
            message.displayNickname = YES;
            message.nickname = @"bete si";
            [messages addObject:message];
        } else {
            NOCImageMessage *message = [[NOCImageMessage alloc] init];
            message.senderId = @"3330";
            message.deliveryStatus = j ? NOCMessageDeliveryStatusDelivering  : NOCMessageDeliveryStatusRead;
            message.outgoing = i ? YES : NO;
            message.displayNickname = YES;
            message.nickname = @"bete si";
            NSArray *imgs = @[@"timg", @"ut"];
            message.image = j ? nil : [UIImage imageNamed:imgs[img]];
            [messages addObject:message];
        }
        
    }
    [self addMessages:messages scrollToBottom:self.isInCurrentBottom animated:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self findImageMessage:nil];
    });
}

- (void)addMessages:(NSArray *)messages scrollToBottom:(BOOL)scrollToBottom animated:(BOOL)animated
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.layoutQueue, ^{
        __strong typeof(weakSelf) strongSelf = self;
        
        NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(self.layouts.count, messages.count)];
        
        NSMutableArray *layouts = [[NSMutableArray alloc] init];
        
        [messages enumerateObjectsUsingBlock:^(NOCMessage *message, NSUInteger idx, BOOL *stop) {
            id<NOCChatItemCellLayout> layout = [strongSelf createLayoutWithItem:message];
            [layouts addObject:layout];
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf insertLayouts:layouts atIndexes:indexes animated:animated];
            if (scrollToBottom) {
                [strongSelf scrollToBottomAnimated:animated];
            }
        });
    });
}

- (void)findMessage:(NOCMessage *)message
{
    [self.layouts enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id<NOCChatItemCellLayout>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        MMBaseMessageCellLayout *layout = obj;
        if ([message.msgId isEqualToString:layout.message.msgId] &&
            layout.message.deliveryStatus == NOCMessageDeliveryStatusDelivering) {
            layout.message.deliveryStatus = NOCMessageDeliveryStatusDelivered;
//            [self updateLayoutAtIndex:idx toLayout:layout animated:YES];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
            UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
            [(MMBaseMessageCell *)cell setupActivityIndicatorHidden];
            *stop = YES;
        }
    }];
    
//    NSArray * visibleCells = self.collectionView.visibleCells;
//    for (MMBaseMessageCell *cell in visibleCells) {
//        MMBaseMessageCellLayout *layout = self.layouts[cell.tag];
//        if ([message.msgId isEqualToString:layout.message.msgId] &&
//            layout.message.deliveryStatus == NOCMessageDeliveryStatusDelivering) {
//            layout.message.deliveryStatus = NOCMessageDeliveryStatusDelivered;
//
//        }
//    }
    
}

- (void)findImageMessage:(NOCImageMessage *)message {
    [self.layouts enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id<NOCChatItemCellLayout>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:MMImageMessageCellLayout.class]) {
            MMImageMessageCellLayout *layout = obj;
            NOCImageMessage *imgMessage = (NOCImageMessage *)layout.message;
            if (!imgMessage.image) {
//                *stop = YES;
                if (layout.message.deliveryStatus == NOCMessageDeliveryStatusDelivering) {
                    layout.message.deliveryStatus = NOCMessageDeliveryStatusDelivered;
                }
                imgMessage.image = [UIImage imageNamed:@"timg"];
                MMImageMessageCellLayout * layout = [self createLayoutWithItem:imgMessage];
                [self updateLayoutAtIndex:idx toLayout:layout animated:NO];
            }
        }
    }];
}

- (void)updateImageLayout:(MMBaseMessageCellLayout *)layout index:(NSInteger)index {
    NOCImageMessage *message = (NOCImageMessage *)layout.message;
    if (!message.image && [layout isKindOfClass:MMImageMessageCellLayout.class]) {
        message.image = [UIImage imageNamed:@"ut"];
        layout = [self createLayoutWithItem:message];
        [self updateLayoutAtIndex:index toLayout:layout animated:YES];
    }
}

@end
