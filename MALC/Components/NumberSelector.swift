//
//  NumberSelector.swift
//  MALC
//
//  Created by Gao Tianrun on 7/10/24.
//

import SwiftUI
import Combine

struct NumberSelector: View {
    @Binding var num: Int
    @State var numString: String
    private var title: String
    private var max: Int
    
    init(_ num: Binding<Int>, _ title: String, _ max: Int) {
        self._num = num
        self.title = title
        self.max = max
        self.numString = String(num.wrappedValue)
    }

    var body: some View {
        if max > 0 && max < 500 {
            Picker(selection: $num, label: Text(title)) {
                ForEach(0...max, id: \.self) { number in
                    Text(String(number))
                }
            }
            .pickerStyle(.menu)
        } else {
            HStack {
                Text(title)
                TextField("", text: $numString)
                    .keyboardType(.numberPad)
                    .onReceive(Just(numString)) { newValue in
                        let filtered = newValue.filter { "0123456789".contains($0) }
                        if filtered != newValue {
                            self.numString = filtered
                        }
                        self.num = Int(numString) ?? 0
                    }
                    .multilineTextAlignment(.trailing)
            }
        }
    }
}
