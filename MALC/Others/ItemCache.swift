//
//  ItemCache.swift
//  MALC
//
//  Created by Gao Tianrun on 20/11/24.
//  Followed https://www.swiftbysundell.com/articles/caching-in-swift/
//

import Foundation

final class ItemCache<Key: Hashable, Value> {
    final class WrappedKey: NSObject {
        let key: Key

        init(_ key: Key) { self.key = key }

        override var hash: Int { return key.hashValue }

        override func isEqual(_ object: Any?) -> Bool {
            guard let value = object as? WrappedKey else {
                return false
            }

            return value.key == key
        }
    }
    
    final class Entry {
        let value: Value

        init(value: Value) {
            self.value = value
        }
    }
    
    private let wrapped = NSCache<WrappedKey, Entry>()
    
    func insert(_ value: Value, _ key: Key) {
        let entry = Entry(value: value)
        wrapped.setObject(entry, forKey: WrappedKey(key))
    }

    func value(_ key: Key) -> Value? {
        let entry = wrapped.object(forKey: WrappedKey(key))
        return entry?.value
    }

    func removeValue(_ key: Key) {
        wrapped.removeObject(forKey: WrappedKey(key))
    }
}

extension ItemCache {
    subscript(key: Key) -> Value? {
        get { return value(key) }
        set {
            guard let value = newValue else {
                // If nil was assigned using our subscript,
                // then we remove any value for that key:
                removeValue(key)
                return
            }

            insert(value, key)
        }
    }
}
