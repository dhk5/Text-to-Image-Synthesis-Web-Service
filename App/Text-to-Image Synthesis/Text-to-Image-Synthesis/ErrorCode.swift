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
    redirectError = -5,
    userCanceled = -6,
    reverseProxyResponseError = -7,
    signInFailed = -8,
    proxyAuthFailed = -9,
    invalidAppState = -10,
    unauthorized = -11,
    generalError = -9999
}
