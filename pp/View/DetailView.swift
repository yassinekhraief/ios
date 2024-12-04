import SwiftUI

struct DetailView: View {
    let country: String
    let travelDate: String
    let durationDays: String
    let placeType: String
    let generatedPlaces: [String] // Array of places with descriptions

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("Your Trip Details")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)

                // Display trip details
                VStack(spacing: 20) {
                    TripDetailCard(title: "Country", value: country)
                    TripDetailCard(title: "Travel Date", value: travelDate)
                    TripDetailCard(title: "Duration", value: "\(durationDays) days")
                    TripDetailCard(title: "Type of Place", value: placeType)
                }

                Divider()

                // Display generated places
                Text("Recommended Destinations")
                    .font(.title2)
                    .bold()
                    .padding(.top)

                ForEach(generatedPlaces, id: \.self) { place in
                    DestinationCard(place: place)
                }

                Spacer()

                Button(action: {
                    // Proceed with booking or other actions
                    print("Proceeding with trip...")
                }) {
                    Text("Proceed to Booking")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding()
            }
            .padding()
            .background(Color(.systemGray6))
        }
        .navigationBarTitle("Trip Details", displayMode: .inline)
    }
}

// A reusable card for trip details
struct TripDetailCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .foregroundColor(.gray)
            Text(value)
                .font(.title3)
                .bold()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.gray.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}

// A reusable card for destination details
struct DestinationCard: View {
    let place: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(place)
                .font(.body)
                .padding()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.gray.opacity(0.2), radius: 4, x: 0, y: 2)
        .padding(.bottom)
    }
}
