//
//  MainViewController.m
//  AWSMobileClientPods
//
//  Created by Ingrid Silapan on 5/08/19.
//  Copyright © 2019 irs. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *actionBtn;
@property (weak, nonatomic) IBOutlet UILabel *userStatusLabel;
@property (assign, nonatomic) AWSMobileUserState userState;
@end

@implementation MainViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	//Initialize every time the app is launched
	[self initializeAWS];
}

- (void)setUserState:(AWSMobileUserState)userState {
	_userState = userState;
	[self updateViewWithState:userState];
}

#pragma mark - Actions

- (IBAction)userSessionBtnPressed:(id)sender {
	
	//Do action based on the user's AWSMobileUserState
	switch (self.userState) {
		case AWSMobileUserStateSignedIn:
			[self signOut];
			break;
		case AWSMobileUserStateSignedOut:
			[self signIn];
			break;
		case AWSMobileUserStateSignedOutUserPoolsTokenInvalid:
			//TODO: Refresh token
			break;
		default:
			break;
	}
	
}


#pragma mark - Private Methods

- (void)initializeAWS {
	
	//Before initialization, set it to unknown
	self.userState = AWSMobileUserStateUnknown;
	
	__weak typeof(self) weakSelf = self;
	
	[AWSMobileClientHelper initializeWithCompletion:^(AWSMobileUserState userState, NSError * _Nullable error) {
		
		//Update UI with state
		if (error == nil) {
			[weakSelf setUserState:userState];
		} else {
			NSLog(@"Error occured with initialization");
		}
		
	}];

}

- (void)updateViewWithState:(AWSMobileUserState) userState {
	__weak typeof(self)	weakSelf = self;
	dispatch_async(dispatch_get_main_queue(), ^{
		switch (userState) {
			case AWSMobileUserStateSignedIn:
				weakSelf.userStatusLabel.text = @"User is signed in.";
				weakSelf.userStatusLabel.backgroundColor = UIColor.greenColor;
				[weakSelf.actionBtn setTitle:@"Log Out" forState:UIControlStateNormal];
				break;
			case AWSMobileUserStateSignedOut:
				weakSelf.userStatusLabel.text = @"User is signed out.";
				weakSelf.userStatusLabel.backgroundColor = UIColor.redColor;
				[weakSelf.actionBtn setTitle:@"Sign In" forState:UIControlStateNormal];
				break;
			case AWSMobileUserStateSignedOutUserPoolsTokenInvalid:
				weakSelf.userStatusLabel.text = @"User pools token is invalid. Need to refresh token.";
				weakSelf.userStatusLabel.backgroundColor = UIColor.orangeColor;
				[weakSelf.actionBtn setTitle:@"Refresh Token" forState:UIControlStateNormal];
				break;
			default:
				//Handle other cases as necessary.
				break;
		}
	});
}

- (void)signOut {
	//Sign out
	[AWSMobileClientHelper signOut];
	//TODO: Need to update the view again after logging out
}

- (void)signIn {
	
	//Validate user credentials
	NSString *username = self.usernameField.text;
	NSString *password = self.passwordField.text;
	
	//Simple validation. Update to more strict check as necessary.
	if ([username length] != 0 && [password length] != 0) {
		__weak typeof(self) weakSelf = self;
		[AWSMobileClientHelper signInUsername:username password:password
								   completion:^(enum AWSMobileUserState userState, BOOL success,
												NSError * _Nullable error) {
									   
									   if (error == nil) {
										   	[weakSelf setUserState:userState];
										   if(userState == AWSMobileUserStateSignedIn) {
											   [weakSelf getTokens];
										   }
									   } else {
										   NSLog(@"Error signing in: %@", error);
									   }
									   
								   }];
	}
		
	
}

- (void)getTokens {
	[AWSMobileClientHelper getTokensWithCompletion:^(NSDictionary * _Nullable tokens, NSError * _Nullable error) {
		if (error == nil) {
			NSLog(@"Tokens retrieved: %@", tokens);
		} else {
			NSLog(@"Error getting tokens: %@", error);
		}
	}];
}

@end
