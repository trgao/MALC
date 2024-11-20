//
//  ImageCache.swift
//  MALC
//
//  Created by Gao Tianrun on 20/11/24.
//

import Foundation

class ImageCache: NSObject, NSDiscardableContent {
    public var image: NSData!

    func beginContentAccess() -> Bool {
        return true
    }

    func endContentAccess() {}

    func discardContentIfPossible() {}

    func isContentDiscarded() -> Bool {
        return false
    }
}
