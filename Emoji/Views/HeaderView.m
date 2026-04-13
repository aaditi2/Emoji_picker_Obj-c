//
//  HeaderView.m
//  Emoji
//



#import "HeaderView.h"

@implementation HeaderView

- (instancetype)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        _titleLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(12, 4, frameRect.size.width - 24, 20)];
        _titleLabel.autoresizingMask = NSViewWidthSizable;
        _titleLabel.textColor = [NSColor secondaryLabelColor];
        _titleLabel.bezeled = NO;
        _titleLabel.drawsBackground = NO;
        _titleLabel.editable = NO;
        _titleLabel.selectable = NO;
        _titleLabel.font = [NSFont systemFontOfSize:13 weight:NSFontWeightMedium];
        
        [self addSubview:_titleLabel];
    }
    return self;
}

@end
