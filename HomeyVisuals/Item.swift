//
//  Item.swift
//  HomeyVisuals
//
//  Created by Brian McAuliff Mulloy on 4/17/25.
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
