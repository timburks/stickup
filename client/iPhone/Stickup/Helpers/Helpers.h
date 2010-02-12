
#import <Foundation/Foundation.h>

@interface NSNumber(Helpers)
- (NSString *) urlEncode;
@end

@interface NSString (Helpers)
- (NSString *) urlEncode;
- (NSString *) urlDecode;
- (NSDictionary *) urlQueryDictionary;
@end

@interface NSDictionary (Helpers)
- (NSString *) urlQueryString;
@end
