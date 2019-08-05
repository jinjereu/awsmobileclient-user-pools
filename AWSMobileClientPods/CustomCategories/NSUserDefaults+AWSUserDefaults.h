//
//  NSUserDefaults.h
//  AWSMobileClientPods
//
//  Created by Ingrid Silapan on 6/08/19.
//  Copyright © 2019 irs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSUserDefaults (AWSUserDefaults)

+(void)setFirstTimeAppRun;
+(BOOL)isFirstTimeAppRun;

@end

NS_ASSUME_NONNULL_END
