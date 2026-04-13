#import "AppDelegate.h"
#import "HeaderView.h"
#import <QuartzCore/QuartzCore.h>

@interface AppDelegate () <NSCollectionViewDataSource, NSCollectionViewDelegate>

@property (strong, nonatomic) NSStatusItem *statusItem;
@property (strong, nonatomic) NSWindow *panel;
@property (strong, nonatomic) NSCollectionView *collectionView;

@property (strong, nonatomic) NSMutableArray *recents;
@property (strong, nonatomic) NSArray *emojis;

@end

@implementation AppDelegate

#pragma mark - Launch

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    self.emojis = @[@"😀",@"😂",@"🥹",@"😍",@"🔥",@"❤️",@"👍",@"🎉",@"😎",@"😭",@"😴",@"🤯",@"🍕",@"☕",@"🚀"];

    NSArray *saved = [[NSUserDefaults standardUserDefaults] objectForKey:@"recents"];
    self.recents = saved ? [saved mutableCopy] : [NSMutableArray array];

    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    self.statusItem.button.title = @"😊";
    self.statusItem.button.target = self;
    self.statusItem.button.action = @selector(toggleWindow);
}

#pragma mark - Panel

- (void)setupPanel {
    
    self.panel = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 260, 360)
                                            styleMask:(NSWindowStyleMaskTitled |
                                                       NSWindowStyleMaskClosable |
                                                       NSWindowStyleMaskResizable)
                                              backing:NSBackingStoreBuffered
                                                defer:NO];

    [self.panel setLevel:NSFloatingWindowLevel];
    [self.panel setTitle:@"Emoji Panel"];

    NSScrollView *scrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, 260, 360)];
    scrollView.hasVerticalScroller = YES;

    self.collectionView = [[NSCollectionView alloc] initWithFrame:scrollView.bounds];
    self.collectionView.selectable = YES;

    NSCollectionViewFlowLayout *layout = [[NSCollectionViewFlowLayout alloc] init];
    layout.itemSize = NSMakeSize(48, 48);
    layout.minimumLineSpacing = 6;
    layout.minimumInteritemSpacing = 6;
    layout.sectionInset = NSEdgeInsetsMake(8, 8, 8, 8);
    layout.headerReferenceSize = NSMakeSize(300, 28);

    self.collectionView.collectionViewLayout = layout;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;

    [self.collectionView registerClass:[NSCollectionViewItem class] forItemWithIdentifier:@"EmojiItem"];
    [self.collectionView registerClass:[HeaderView class]
        forSupplementaryViewOfKind:NSCollectionElementKindSectionHeader
               withIdentifier:@"HeaderView"];

    scrollView.documentView = self.collectionView;
    [self.panel.contentView addSubview:scrollView];
}

#pragma mark - Toggle

- (void)toggleWindow {
    if (!self.panel) {
        [self setupPanel];
    }

    if (self.panel.isVisible) {
        [self.panel orderOut:nil];
    } else {
        [self.panel makeKeyAndOrderFront:nil];
        [NSApp activateIgnoringOtherApps:YES];
    }
}

#pragma mark - Sections

- (NSInteger)numberOfSectionsInCollectionView:(NSCollectionView *)collectionView {
    return 2;
}

- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) return self.recents.count;
    return self.emojis.count;
}

#pragma mark - Cells

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath {
    
    NSCollectionViewItem *item = [collectionView makeItemWithIdentifier:@"EmojiItem" forIndexPath:indexPath];
    
    NSString *emoji;
    if (indexPath.section == 0) {
        emoji = self.recents[indexPath.item];
    } else {
        emoji = self.emojis[indexPath.item];
    }

    for (NSView *subview in item.view.subviews) {
        [subview removeFromSuperview];
    }

    NSTextField *label = [[NSTextField alloc] initWithFrame:item.view.bounds];
    label.stringValue = emoji;
    label.alignment = NSTextAlignmentCenter;
    label.bezeled = NO;
    label.drawsBackground = NO;
    label.editable = NO;
    label.selectable = NO;
    label.font = [NSFont systemFontOfSize:28];

    [item.view addSubview:label];

    return item;
}

#pragma mark - Headers

- (NSView *)collectionView:(NSCollectionView *)collectionView
viewForSupplementaryElementOfKind:(NSString *)kind
                atIndexPath:(NSIndexPath *)indexPath {

    HeaderView *header = [collectionView makeSupplementaryViewOfKind:kind
                                                     withIdentifier:@"HeaderView"
                                                        forIndexPath:indexPath];

    header.titleLabel.stringValue = (indexPath.section == 0)
        ? @"Recently Used"
        : @"All Emojis";

    return header;
}

#pragma mark - Selection

- (void)collectionView:(NSCollectionView *)collectionView didSelectItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths {
    
    NSIndexPath *indexPath = indexPaths.anyObject;

    NSString *emoji = (indexPath.section == 0)
        ? self.recents[indexPath.item]
        : self.emojis[indexPath.item];

    [self.recents removeObject:emoji];
    [self.recents insertObject:emoji atIndex:0];

    if (self.recents.count > 3) {
        [self.recents removeLastObject];
    }

    [[NSUserDefaults standardUserDefaults] setObject:self.recents forKey:@"recents"];

    [collectionView reloadData];

    [self insertEmoji:emoji];
    [self showCopiedToast];
}

#pragma mark - Paste

- (void)insertEmoji:(NSString *)emoji {
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard clearContents];
    [pasteboard setString:emoji forType:NSPasteboardTypeString];
}

#pragma mark - Toast

- (void)showCopiedToast {
    
    CGFloat width = 70;
    CGFloat height = 35;

    NSView *toast = [[NSView alloc] initWithFrame:NSMakeRect(
        (self.panel.contentView.bounds.size.width - width)/2,
        (self.panel.contentView.bounds.size.height - height)/2,
        width,
        height
    )];
    toast.wantsLayer = YES;
    toast.layer.backgroundColor = [[NSColor blackColor] colorWithAlphaComponent:0.85].CGColor;
    toast.layer.cornerRadius = 10;

    NSTextField *label = [[NSTextField alloc] init];
    label.stringValue = @"Copied!";
    label.alignment = NSTextAlignmentCenter;
    label.bezeled = NO;
    label.drawsBackground = NO;
    label.editable = NO;
    label.selectable = NO;
    label.textColor = NSColor.whiteColor;
    label.font = [NSFont systemFontOfSize:13 weight:NSFontWeightMedium];

    label.translatesAutoresizingMaskIntoConstraints = NO;
    [toast addSubview:label];

    [NSLayoutConstraint activateConstraints:@[
        [label.centerXAnchor constraintEqualToAnchor:toast.centerXAnchor],
        [label.centerYAnchor constraintEqualToAnchor:toast.centerYAnchor]
    ]];

    [self.panel.contentView addSubview:toast];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [toast removeFromSuperview];
    });
}

@end
