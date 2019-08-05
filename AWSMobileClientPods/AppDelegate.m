//
//  AppDelegate.m
//  AWSMobileClientPods
//
//  Created by Ingrid Silapan on 5/08/19.
//  Copyright © 2019 irs. All rights reserved.
//

#import "AppDelegate.h"
#import "NSUserDefaults+AWSUserDefaults.h"
#import "AWSMobileClientPods-Swift.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// Override point for customization after application launch.
	
	//When app launched check if first time to run the app
	if([NSUserDefaults isFirstTimeAppRun]) {
		
		//If first time, perform the sign out to refresh AWS Credentials on first install.
		[AWSMobileClientHelper signOut];
		
		//Then set value of isFirstTime
		[NSUserDefaults setFirstTimeAppRun];
	} else {
		//Initialize AWS
		
	}
	
	return YES;
}

@end
