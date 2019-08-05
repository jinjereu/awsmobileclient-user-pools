//
//  NSUserDefaults.m
//  AWSMobileClientPods
//
//  Created by Ingrid Silapan on 6/08/19.
//  Copyright © 2019 irs. All rights reserved.
//

#import "NSUserDefaults+AWSUserDefaults.h"

#define kFirstTimeAppRun @"kFirstTimeAppRun"

@implementation NSUserDefaults (AWSUserDefaults)

+(void)setFirstTimeAppRun {
	[[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kFirstTimeAppRun];
}

+(BOOL)isFirstTimeAppRun {
	return [[NSUserDefaults standardUserDefaults] objectForKey:kFirstTimeAppRun] == nil;
}

@end
