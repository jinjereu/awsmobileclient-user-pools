//
//  macros.swift
//  AWSMobileClientPods
//
//  Created by Ingrid Silapan on 5/08/19.
//  Copyright © 2019 irs. All rights reserved.
//

import Foundation

#if DEBUG
func dLog(_ message: String, filename: String = #file, function: String = #function, line: Int = #line) {
	if let fileNameURL = NSURL(fileURLWithPath: filename).lastPathComponent {
		NSLog("[\(fileNameURL):\(line)] \(function) - \(message)")
	}
}
#else
func dLog(_ message: String, filename: String = #file, function: String = #function, line: Int = #line) {
}
#endif

