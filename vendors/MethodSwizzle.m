//
//  MethodSwizzle.m
//  Salento Camping
//
//  Created by Francesco Piero Paolicelli on 05/03/13.
//  Copyright (c) 2013 Francesco Piero Paolicelli. All rights reserved.
//

#import "MethodSwizzle.h"
#import <MessageUI/MessageUI.h>

@implementation MFMailComposeViewController (force_subject)

- (void)setMessageBodySwizzled:(NSString*)body isHTML:(BOOL)isHTML
{
    
    if (isHTML == YES) {
       
        NSRange range = [body rangeOfString:@"<title>.*</title>" options:NSRegularExpressionSearch|NSCaseInsensitiveSearch];
        if (range.location != NSNotFound) {
            NSScanner *scanner = [NSScanner scannerWithString:body];
            [scanner setScanLocation:range.location+7];
            NSString *subject = [NSString string];
            if ([scanner scanUpToString:@"</title>" intoString:&subject] == YES) {
                NSLog(@"subject %@",subject);
                [self setSubject:subject];
            }
        }
    }
    
 
    [self setMessageBodySwizzled:body isHTML:isHTML];
}

@end