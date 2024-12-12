//
//  TripPlanificationView.swift
//  pp
//
//  Created by Apple Esprit on 12/12/2024.
//

import SwiftUI

struct TripPlanificationView: View {
    @ObservedObject var viewModel: TripPlannerViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Trip Summary
                Text("Trip Summary")
                    .font(.title)
                    .fontWeight(.bold)
                
                Group {
                    Text("Destination: \(viewModel.tripPreferences.destination)")
                    Text("Dates: \(formatDateRange())")
                    Text("Travelers: \(viewModel.tripPreferences.travelerCount.rawValue)")
                    Text("Duration: \(viewModel.calculateDuration()) days")
                }
                .foregroundColor(.secondary)
                
                // Interests-based Recommendations
                Text("Recommendations")
                    .font(.title2)
                    .fontWeight(.bold)
                
                ForEach(generateRecommendations(), id: \.self) { recommendation in
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text(recommendation)
                    }
                }
                
                // Basic Itinerary
                Text("Suggested Itinerary")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Day 1: Arrival and Initial Exploration")
                Text("Day 2: Local Attractions")
                Text("Day 3: Activities Based on Interests")
                // Add more days as needed
            }
            .padding()
        }
        .navigationTitle("Trip Planification")
    }
    
    // Helper method to format date range
    private func formatDateRange() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return "\(formatter.string(from: viewModel.tripPreferences.startDate)) - \(formatter.string(from: viewModel.tripPreferences.endDate))"
    }
    
    // Generate recommendations based on interests
    private func generateRecommendations() -> [String] {
        var recommendations: [String] = []
        
        for interest in viewModel.tripPreferences.interests {
            switch interest {
            case "Culture":
                recommendations.append("Visit local museums")
                recommendations.append("Explore historical sites")
            case "Food":
                recommendations.append("Food tour")
                recommendations.append("Local cuisine cooking class")
            case "Adventure":
                recommendations.append("Outdoor activities")
                recommendations.append("Hiking or water sports")
            case "Nature":
                recommendations.append("National park visit")
                recommendations.append("Wildlife watching")
            default:
                break
            }
        }
        
        return recommendations
    }
}


struct TripPlanificationView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = TripPlannerViewModel()
        viewModel.tripPreferences.destination = "Paris, France"
        viewModel.tripPreferences.startDate = Date()
        viewModel.tripPreferences.endDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
        viewModel.tripPreferences.interests = ["Culture", "Food"]
        
        return TripPlanificationView(viewModel: viewModel)
    }
}
