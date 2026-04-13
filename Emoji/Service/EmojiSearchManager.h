//
//  EmojiSearchManager.h
//  Emoji
//



#import <Foundation/Foundation.h>

@interface EmojiSearchManager : NSObject

- (NSArray *)filterEmojis:(NSDictionary *)emojiKeywords
                   query:(NSString *)query;

@end
