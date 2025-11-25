//
//  LogDebug.swift
//  SafepayiOSSDK
//
//  Created by Irfan Gul on 10/28/24.
//

import Foundation

func debugPrint(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    #if DEBUG
    let fileName = (file as NSString).lastPathComponent
    print("[\(fileName):\(line)] \(function) - \(message)")
    #endif
}
