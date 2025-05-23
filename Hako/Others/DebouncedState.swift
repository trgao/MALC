//
//  DebounceState.swift
//  Code taken from https://gist.github.com/CodeSlicing/026d8481dea0e4f5f5da85ea4dce6fc4
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
//  of the Software, and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
//  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
//  PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
//  AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//  Copyright © 2022 Adam Fordyce. All rights reserved.
//

import SwiftUI
import Combine

@propertyWrapper
struct DebouncedState<Value>: DynamicProperty {

    @StateObject private var backingState: BackingState<Value>
    
    init(initialValue: Value, delay: Double = 0.3) {
        self.init(wrappedValue: initialValue, delay: delay)
    }
    
    init(wrappedValue: Value, delay: Double = 0.3) {
        self._backingState = StateObject(wrappedValue: BackingState<Value>(originalValue: wrappedValue, delay: delay))
    }
    
    var wrappedValue: Value {
        get {
            backingState.debouncedValue
        }
        nonmutating set {
            backingState.currentValue = newValue
        }
    }
    
    public var projectedValue: Binding<Value> {
        Binding {
            backingState.currentValue
        } set: {
            backingState.currentValue = $0
        }
    }
    
    private class BackingState<BackingValue>: ObservableObject {
        @Published var currentValue: BackingValue
        @Published var debouncedValue: BackingValue

        init(originalValue: BackingValue, delay: Double) {
            _currentValue = Published(initialValue: originalValue)
            _debouncedValue = Published(initialValue: originalValue)
            $currentValue
                .debounce(for: .seconds(delay), scheduler: RunLoop.main)
                .assign(to: &$debouncedValue)
        }
    }
}
