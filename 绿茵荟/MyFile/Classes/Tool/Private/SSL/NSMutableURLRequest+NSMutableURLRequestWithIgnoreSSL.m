//
//  NSURLRequestWithIgnoreSSL.m
//  绿茵荟
//
//  Created by Mac on 17/5/25.
//  Copyright © 2017年 杜浩. All rights reserved.
//

#import "NSMutableURLRequest+NSMutableURLRequestWithIgnoreSSL.h"

@implementation NSURLRequest (NSMutableURLRequestWithIgnoreSSL)

+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host
{
    return YES;
}

@end
