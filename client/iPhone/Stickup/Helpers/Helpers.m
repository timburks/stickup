

#import "Helpers.h"
#import <wctype.h>

@implementation NSNumber(Helpers)

- (NSString *) urlEncode 
{
	return [self stringValue];
}
@end

static unichar char_to_int(unichar c)
{
    switch (c) {
        case '0': return 0;
        case '1': return 1;
        case '2': return 2;
        case '3': return 3;
        case '4': return 4;
        case '5': return 5;
        case '6': return 6;
        case '7': return 7;
        case '8': return 8;
        case '9': return 9;
        case 'A': case 'a': return 10;
        case 'B': case 'b': return 11;
        case 'C': case 'c': return 12;
        case 'D': case 'd': return 13;
        case 'E': case 'e': return 14;
        case 'F': case 'f': return 15;
    }
    return 0;                                     // not good
}

static char int_to_char[] = "0123456789ABCDEF";

@implementation NSString (Helpers)

- (NSString *) urlEncode
{
    NSMutableString *result = [NSMutableString string];
    int i = 0;
    const char *source = [self cStringUsingEncoding:NSUTF8StringEncoding];
    int max = strlen(source);
    while (i < max) {
        unsigned char c = source[i++];
        if (c == ' ') {
            [result appendString:@"+"];
        }
        else if (iswalpha(c) || iswdigit(c) || (c == '-') || (c == '.') || (c == '_') || (c == '~')) {
            [result appendFormat:@"%c", c];
        }
        else {
            [result appendString:[NSString stringWithFormat:@"%%%c%c", int_to_char[(c/16)%16], int_to_char[c%16]]];
        }
    }
    return result;
}

- (NSString *) urlDecode
{
    int i = 0;
    int max = [self length];
    char *buffer = (char *) malloc (max * sizeof(char));
    int j = 0;
    while (i < max) {
        char c = [self characterAtIndex:i++];
        switch (c) {
            case '+':
                buffer[j++] = ' ';
                break;
            case '%':
                buffer[j++] =
				char_to_int([self characterAtIndex:i])*16
				+ char_to_int([self characterAtIndex:i+1]);
                i = i + 2;
                break;
            default:
                buffer[j++] = c;
                break;
        }
    }
    buffer[j] = 0;
    NSString *result = [NSMutableString stringWithCString:buffer encoding:NSUTF8StringEncoding];
    if (!result) result = [NSMutableString stringWithCString:buffer encoding:NSASCIIStringEncoding];
    return result;
}

- (NSDictionary *) urlQueryDictionary
{
	NSMutableDictionary *result = [NSMutableDictionary dictionary];
	NSArray *pairs = [self componentsSeparatedByString:@"&"];
	int i;
	int max = [pairs count];
	for (i = 0; i < max; i++) {
		NSArray *pair = [[pairs objectAtIndex:i] componentsSeparatedByString:@"="];
		if ([pair count] == 2) {
			NSString *key = [[pair objectAtIndex:0] urlDecode];
			NSString *value = [[pair objectAtIndex:1] urlDecode];
			[result setObject:value forKey:key];
		}
	}
	return result;
}

@end

@implementation NSDictionary (Helpers)

- (NSString *) urlQueryString
{
	NSMutableString *result = [NSMutableString string];
	NSEnumerator *keyEnumerator = [[[self allKeys] sortedArrayUsingSelector:@selector(compare:)] objectEnumerator];
	id key;
	while (key = [keyEnumerator nextObject]) {
		if ([result length] > 0) [result appendString:@"&"];
		[result appendString:[NSString stringWithFormat:@"%@=%@", [key urlEncode], [[self objectForKey:key] urlEncode]]];
	}
	return [NSString stringWithString:result];
}


@end

