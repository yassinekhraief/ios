//
//  TripModel.swift
//  TripPlannerApp
//
//  Created by Apple Esprit on 12/12/2024.
//

import Foundation
import SwiftUI

struct Trip: Identifiable {
    let id = UUID()
    var destination: String
    var startDate: Date
    var endDate: Date
    var numberOfTravelers: Int
    var interests: [String]
}
