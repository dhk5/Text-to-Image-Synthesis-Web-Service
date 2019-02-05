//
//  ErrorCode.swift
//  Text-to-Image-Synthesis
//
//  Created by Ryan Kang on 1/13/19.
//

import Foundation

public let ErrorDomain: String = "Text-to-Image Synthesis"

public enum ErrorCode: Int {
    case
    notImplemented = -1,
    unexpectedServerResponse = -2,
    invalidServerResponse = -3,
    invalidUrl = -4,
    invalidAppState = -5,
    generalError = -6
}
