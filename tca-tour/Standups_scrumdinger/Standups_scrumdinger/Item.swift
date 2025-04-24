//
//  Item.swift
//  Standups_scrumdinger
//
//  Created by Soop on 4/24/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
