//
//  StatusEnum.swift
//  MALC
//
//  Created by Gao Tianrun on 15/5/24.
//

import Foundation

enum StatusEnum: Codable {
    case watching, completed, onHold, dropped, planToWatch, reading, planToRead, none
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let status = try? container.decode(String.self)
        switch status {
        case "watching": self = .watching
        case "completed": self = .completed
        case "on_hold": self = .onHold
        case "dropped": self = .dropped
        case "plan_to_watch": self = .planToWatch
        case "reading": self = .reading
        case "plan_to_read": self = .planToRead
        default:
            self = .none
        }
    }
    
    func toParameter() -> String {
        if self == .watching {
            return "watching"
        } else if self == .completed {
            return "completed"
        } else if self == .onHold {
            return "on_hold"
        } else if self == .dropped {
            return "dropped"
        } else if self == .planToWatch {
            return "plan_to_watch"
        } else if self == .reading {
            return "reading"
        } else if self == .planToRead {
            return "plan_to_read"
        } else {
            return ""
        }
    }
    
    func toString() -> String {
        if self == .watching {
            return "Watching"
        } else if self == .completed {
            return "Completed"
        } else if self == .onHold {
            return "On Hold"
        } else if self == .dropped {
            return "Dropped"
        } else if self == .planToWatch {
            return "Plan To Watch"
        } else if self == .reading {
            return "Reading"
        } else if self == .planToRead {
            return "Plan To Read"
        } else {
            return ""
        }
    }
}
