//
//  DKDrawableObjectAdditions.swift
//  DrawKitSwift
//
//  Created by C.W. Betts on 12/18/17.
//  Copyright © 2017 DrawKit. All rights reserved.
//

import DKDrawKit.DKDrawableObject

extension DKDrawableObject {
	/// Attach a dictionary of metadata to the object.
	///
	/// The setter replaces the current user info. To merge with any existing user info, use `addUserInfo(_:)`.
	public var userInfo: [String: Any] {
		get {
			return __userInfo() as NSDictionary as! [String: Any]
		}
		set {
			__setUserInfo(newValue)
		}
	}
}
