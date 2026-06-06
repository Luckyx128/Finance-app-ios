//
//  Item.swift
//  finance
//
//  Created by Lucas de Amorim on 06/06/26.
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
