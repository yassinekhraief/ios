import SwiftUI

struct SuggestionsView: View {
    var country: String
    var travelDate: String
    var durationDays: String
    var placeType: String
    var suggestions: [String]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // Title Section
                Text("Your Travel Preferences")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                    .padding(.bottom, 10)
                
                VStack(alignment: .leading, spacing: 8) {
                    InfoRow(label: "Country", value: country)
                    InfoRow(label: "Travel Date", value: travelDate)
                    InfoRow(label: "Duration", value: "\(durationDays) days")
                    InfoRow(label: "Type of Place", value: placeType)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 5)
                
                Divider()
                    .padding(.vertical)
                
                // Suggested Destinations Section
                Text("Day-by-Day Travel Plan")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                    .padding(.bottom, 5)
                
                if suggestions.isEmpty {
                    Text("No suggestions available.")
                        .font(.body)
                        .foregroundColor(.gray)
                        .italic()
                        .padding(.top)
                } else {
                    ForEach(suggestions.indices, id: \.self) { index in
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Day \(index + 1):")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                
                                Spacer()
                            }
                            
                            Text(suggestions[index])
                                .font(.body)
                                .foregroundColor(.black)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Travel Suggestions")
        .background(Color(.systemGray6).edgesIgnoringSafeArea(.all))
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text("\(label):")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
}

struct SuggestionsView_Previews: PreviewProvider {
    static var previews: some View {
        SuggestionsView(
            country: "France",
            travelDate: "2024-12-15",
            durationDays: "7",
            placeType: "beach",
            suggestions: [
                "Nice Beach in Nice",
                "Corsica Island",
                "Biarritz Surfing Spot",
                "Saint-Tropez Harbor",
                "Mont Saint-Michel",
                "Etretat Cliffs",
                "Cannes Boulevard"
            ]
        )
    }
}
