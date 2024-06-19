//
//  DateTime.swift
//  MALC
//
//  Created by Gao Tianrun on 22/5/24.
//

import Foundation

protocol HasDateFormatter {
    static var dateFormatter: DateFormatter { get }
}

struct DateTime<E:HasDateFormatter>: Codable {
    var value: Date
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let text = try container.decode(String.self)
        guard let date = E.dateFormatter.date(from: text) else {
            throw CustomDateError.general
        }
        self.value = date
    }
    
    enum CustomDateError: Error {
        case general
    }
}

struct ISO8601Date: HasDateFormatter {
    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return formatter
    }
}

struct NormalDate: HasDateFormatter {
    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-mm-dd"
        return formatter
    }
}
