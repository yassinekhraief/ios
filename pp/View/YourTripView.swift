import SwiftUI

struct Activity: Hashable {
    var name: String
    var icon: String
}

struct YourTripView: View {
    var country: String
    var duration: String
    var dates: String
    var activities: [Activity]

    // Function to fetch the image name for a given country
    func imageForCountry(_ country: String) -> String {
        let countryImages: [String: String] = [
            "Spain": "spain",     // Replace with the actual image names in your assets
            "Italy": "italy",
            "Germany": "germany",
            "Japan": "japan",

        ]
        return countryImages[country] ?? "default_image" // Fallback to a default image
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Dynamically fetch image based on the country
                Image(imageForCountry(country))
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .clipped()

                ZStack {
                    Color.blue
                        .frame(height: 140)
                        .cornerRadius(15)

                    VStack(alignment: .leading) {
                        Text(duration)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color.white)
                            .underline()

                        Spacer().frame(height: 5)

                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.white)
                            Text(dates)
                                .font(.subheadline)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.leading, 20)
                }
                .padding(.horizontal, 20)

                ForEach(activities, id: \.self) { activity in
                    HStack {
                        Image(systemName: activity.icon)
                            .padding()
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(10)

                        Text(activity.name)
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 20)
                }

                Spacer()
            }
            .navigationBarTitle("Your Trip", displayMode: .inline)
        }
    }
}

struct YourTripView_Previews: PreviewProvider {
    static var previews: some View {
        YourTripView(
            country: "Italy",
            duration: "7 Days",
            dates: "10th Dec - 17th Dec",
            activities: [
                Activity(name: "Visit the Colosseum", icon: "building.columns.fill"),
                Activity(name: "Gondola Ride", icon: "wave.3.left.circle.fill"),
                Activity(name: "Pizza Tasting", icon: "fork.knife.circle.fill")
            ]
        )
    }
}
