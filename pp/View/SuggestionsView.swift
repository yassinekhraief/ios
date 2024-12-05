import SwiftUI

struct SuggestionsView: View {
    var country: String
    var travelDate: String
    var durationDays: String
    var placeType: String
    var suggestions: [String]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 25) {
                
                // Title Section
                Text("Your Travel Preferences")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Country: \(country)")
                    Text("Travel Date: \(travelDate)")
                    Text("Duration: \(durationDays) days")
                    Text("Type of Place: \(placeType)")
                }
                .font(.body)
                .foregroundColor(.gray)
                
                Divider()
                    .padding(.vertical)
                
                // Suggested Destinations Section
                Text("Suggested Destinations")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                
                if suggestions.isEmpty {
                    Text("No suggestions available.")
                        .font(.body)
                        .foregroundColor(.gray)
                        .italic()
                        .padding(.top)
                } else {
                    ForEach(suggestions, id: \.self) { suggestion in
                        VStack(alignment: .leading) {
                            Text(suggestion)
                                .font(.body)
                                .foregroundColor(.black)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                                .padding(.bottom, 10)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Travel Suggestions")
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
}

struct SuggestionsView_Previews: PreviewProvider {
    static var previews: some View {
        SuggestionsView(country: "France", travelDate: "2024-12-15", durationDays: "7", placeType: "beach", suggestions: ["Nice Beach in Nice", "Corsica Island", "Biarritz Surfing Spot"])
    }
}
