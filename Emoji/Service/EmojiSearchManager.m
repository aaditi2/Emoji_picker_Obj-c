//
//  EmojiSearchManager.m
//  Emoji
//



#import "EmojiSearchManager.h"

@implementation EmojiSearchManager

- (NSArray *)filterEmojis:(NSDictionary *)emojiKeywords
                   query:(NSString *)query {
    
    if (query.length == 0) {
        return emojiKeywords.allKeys;
    }

    NSString *lowerQuery = query.lowercaseString;
    NSMutableArray *results = [NSMutableArray array];

    for (NSString *emoji in emojiKeywords) {
        NSArray *keywords = emojiKeywords[emoji];

        for (NSString *word in keywords) {
            if ([word localizedCaseInsensitiveContainsString:lowerQuery]) {
                [results addObject:emoji];
                break;
            }
        }
    }

    return results;
}

@end
