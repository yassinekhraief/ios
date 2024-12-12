//
//  TripViewModel.swift
//  TripPlannerApp
//
//  Created by Apple Esprit on 12/12/2024.
//

import Foundation
import SwiftUI
import Combine

class TripViewModel: ObservableObject {
    @Published var destination = ""
    @Published var startDate = Date()
    @Published var endDate = Date()
    @Published var numberOfTravelers = 1
    @Published var interests: [String] = []
    @Published var isTripsPlanned = false
    
    let possibleInterests = [
        "Culture", "Food", "Adventure",
        "Nature", "History", "Relaxation",
        "Shopping", "Nightlife"
    ]
    
    func planTrip() {
        // Validate input
        guard !destination.isEmpty else { return }
        
        // Prepare trip details
        let trip = Trip(
            destination: destination,
            startDate: startDate,
            endDate: endDate,
            numberOfTravelers: numberOfTravelers,
            interests: interests
        )
        
        // In a real app, you might save this to Core Data or send to a backend
        print("Trip Planned: \(trip)")
        
        // Trigger navigation to planningview
        isTripsPlanned = true
    }
}
