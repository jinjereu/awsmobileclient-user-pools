//
//  AWSMobileClientHelper.swift
//  AWSMobileClientPods
//
//  Created by Ingrid Silapan on 5/08/19.
//  Copyright © 2019 irs. All rights reserved.
//

import Foundation
import AWSMobileClient
import AWSCore

@objc public enum AWSMobileUserState : Int {
	case SignedIn = 0
	case SignedOut = 1
	case SignedOutFederatedTokensInvalid = 2
	case SignedOutUserPoolsTokenInvalid = 3
	case Guest = 4
	case Unknown = 5
}

@objcMembers
class AWSMobileClientHelperNotification: NSObject {
	static let UserStateChanged = "AWSMobileClientHelperUserStateChanged";
}

class AWSMobileClientHelper: NSObject {
	
	static func genericError() -> NSError {
		let userInfo = [NSLocalizedDescriptionKey : "Generic Error"]
		let error = NSError(domain: "AWSMobileClientHelper",
							code: 0,
							userInfo: userInfo)
		
		return error
	}
	
	@objc public static func enableVerboseLogging() {
		AWSDDLog.sharedInstance.logLevel = .verbose;
		AWSDDLog.sharedInstance.add(AWSDDTTYLogger.sharedInstance);
	}
	
	@objc public static func sharedAWSMobileClient() -> AWSMobileClient {
		return AWSMobileClient.sharedInstance();
	}
	
	@objc public static func initialize(withCompletion
		completion: @escaping (_ userState: AWSMobileUserState, _ error: NSError?) -> Void) {
		
		AWSMobileClient.sharedInstance().initialize { (userState, error) in
			if let userState = userState {
				print("UserState: \(userState.rawValue)")
				
				switch userState {
				case .signedOut:
					print("User is signed out. Log in!")
					completion(.SignedOut, nil)
				case .signedIn:
					print("Awesome, return the tokens")
					completion(.SignedIn, nil)
				case .signedOutUserPoolsTokenInvalid:
					print("Refresh token expired get the tokens")
					completion(.SignedOutUserPoolsTokenInvalid, nil)
				case .signedOutFederatedTokensInvalid:
					print("Federated tokens invalid")
					completion(.SignedOutFederatedTokensInvalid, nil)
				case .guest:
					print("User has guest access")
					completion(.Guest, nil)
				default:
					completion(.Unknown, nil)
				}

			} else if let error = error as NSError? {
				print("error: \(error.localizedDescription)")
				completion(.Unknown, error)
			}
		}
	}
	
	@objc public static func signOut() {
		AWSMobileClient.sharedInstance().signOut()
		AWSMobileClient.sharedInstance().clearCredentials()
		//TODO: put back
		//self.removeUserStateListeners()
	}
	
	@objc public static func checkIfLoggedIn() -> Bool {
		return AWSMobileClient.sharedInstance().isLoggedIn;
	}
	
	@objc public static func signIn(username: String, password: String,
									completion: @escaping (_ userState: AWSMobileUserState, _ success: Bool, _ error: NSError?) -> Void) {
		
		AWSMobileClient.sharedInstance().signIn(username: username, password: password) { (signInResult, error) in
			if let error = error  {
				print("\(error.localizedDescription)")
				
				let userInfo = [NSLocalizedDescriptionKey : error.localizedDescription]
				let error = NSError(domain: "AWSMobileClientHelper",
									code: 0,
									userInfo: userInfo)
				
				completion(.Unknown, false, error)
				
			} else if let signInResult = signInResult {
				switch (signInResult.signInState) {
				case .signedIn:
					dLog("User is signed in.")
					completion(.SignedIn, true, nil)
				default:
					//Add in other cases as necessary
					dLog("Unhandled sign-in case.")
					completion(.Unknown, false, genericError())
				}
			}
		}
	}
	
	@objc public static func getTokens(completion: @escaping (_ tokens: NSDictionary?, _ error: NSError?) -> Void) {
		AWSMobileClient.sharedInstance().getTokens { (tokens, error) in
			
			if let error = error {
				dLog("Error getting token \(error.localizedDescription)")
				completion(nil, error as NSError)
			}
			else if let tokens = tokens {
				var tokensDict = [String: Any]()
				if let accessToken = tokens.accessToken?.tokenString {
					tokensDict["accessToken"] = accessToken
				}
				if let refreshToken = tokens.refreshToken?.tokenString {
					tokensDict["refreshToken"] = refreshToken
				}
				if let idToken = tokens.idToken?.tokenString {
					tokensDict["idToken"] = idToken
				}
				if let expiration = tokens.expiration {
					tokensDict["expiration"] = expiration
				}
				
				dLog("Tokens Dictionary: \(tokensDict)")
				
				completion(NSDictionary.init(dictionary: tokensDict), nil)
			}
			
		}
	}
	
	@objc public static func addUserStateListeners() {
		dLog("Adding state listeners...")
		
		AWSMobileClient.sharedInstance().addUserStateListener(self) { (userState, info) in
			switch (userState) {
			case .guest:
				dLog("User is in guest mode.")
			case .signedOut:
				dLog("User is signed out.")
			case .signedIn:
				dLog("User is signed in.")
			case .signedOutUserPoolsTokenInvalid:
				dLog("Invalid user pool token. re-login required.")
				let userStateInfo: [String: Int] = ["userState": AWSMobileUserState.SignedOutUserPoolsTokenInvalid.rawValue]
				
				NotificationCenter.default.post(name: NSNotification.Name(rawValue: AWSMobileClientHelperNotification.UserStateChanged),
												object: nil,
												userInfo: userStateInfo)
			case .signedOutFederatedTokensInvalid:
				dLog("Invalid federated tokens.") //This shouldn't happen in our case
			default:
				dLog("Unsupported user state.")
			}
		}
	}
	
	@objc public static func removeUserStateListeners() {
		dLog("Removing state listeners...")
		AWSMobileClient.sharedInstance().removeUserStateListener(self);
	}
	
	@objc public static func checkCurrentUserState() -> AWSMobileUserState {
		let userState: UserState = AWSMobileClient.sharedInstance().currentUserState
		switch (userState) {
		case .guest:
			dLog("user is in guest mode.")
			return .Guest
		case .signedOut:
			dLog("user signed out")
			return .SignedOut
		case .signedIn:
			dLog("user is signed in.")
		case .signedOutUserPoolsTokenInvalid:
			dLog("need to login again.")
			return .SignedOutUserPoolsTokenInvalid
		case .signedOutFederatedTokensInvalid:
			dLog("user logged in via federation, but currently needs new tokens")
			return .SignedOutFederatedTokensInvalid
		default:
			dLog("unsupported")
			return AWSMobileUserState.Unknown
		}
		return AWSMobileUserState.Unknown
		
	}
	
}
