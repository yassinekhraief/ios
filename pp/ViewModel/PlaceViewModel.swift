import SwiftUI
import CoreData

class PlaceViewModel: ObservableObject {
    @Published var selectedCountry: String = "Italy"
    @Published var selectedCategory: String = "Beach"
    @Published var selectedStartDate: Date = Date() // Default to today's date
    @Published var selectedEndDate: Date = Date().addingTimeInterval(86400 * 3) // Default to three days later

    var countries = ["Italy", "France", "Spain", "Japan"]
    var categories = ["Beach", "Museums", "Cities"]
    
    @Published var places: [Place] = []
    
    private var context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
        fetchPlaces()
        seedInitialData()
    }
    
    func fetchPlaces() {
        let request: NSFetchRequest<Place> = Place.fetchRequest()
        
        do {
            let allPlaces = try context.fetch(request)
            places = allPlaces
        } catch {
            print("Failed to fetch places: \(error)")
        }
    }
    
    func seedInitialData() {
        let fetchRequest: NSFetchRequest<Place> = Place.fetchRequest()
        fetchRequest.fetchLimit = 1
        
        do {
            let count = try context.count(for: fetchRequest)
            if count == 0 {
                let places = [
                    // Italy - Beach (5 places)
                    ("Italy", "Beach", "Amalfi Coast Beach", "A stunning beach on the Amalfi Coast.", Date(), Date().addingTimeInterval(86400), 1),
                    ("Italy", "Beach", "Sardinia Beaches", "Beautiful sandy beaches in Sardinia.", Date().addingTimeInterval(86400), Date().addingTimeInterval(86400 * 2), 1),
                    ("Italy", "Beach", "Cinque Terre Beaches", "Breathtaking beaches in the Cinque Terre region.", Date().addingTimeInterval(86400 * 2), Date().addingTimeInterval(86400 * 3), 1),
                    ("Italy", "Beach", "Sicily Beaches", "Relax on the pristine beaches of Sicily.", Date().addingTimeInterval(86400 * 3), Date().addingTimeInterval(86400 * 4), 1),
                    ("Italy", "Beach", "Capri Island Beach", "A gorgeous beach on the island of Capri.", Date().addingTimeInterval(86400 * 4), Date().addingTimeInterval(86400 * 5), 1),
                    
                    // France - Museums (5 places)
                    ("France", "Museums", "Louvre Museum", "The world's largest museum and a historic monument in Paris.", Date().addingTimeInterval(86400 * 5), Date().addingTimeInterval(86400 * 6), 2),
                    ("France", "Museums", "Musée d'Orsay", "A famous museum housed in a former railway station in Paris.", Date().addingTimeInterval(86400 * 6), Date().addingTimeInterval(86400 * 7), 2),
                    ("France", "Museums", "Centre Pompidou", "A modern art museum in the center of Paris.", Date().addingTimeInterval(86400 * 7), Date().addingTimeInterval(86400 * 8), 2),
                    ("France", "Museums", "Palace of Versailles", "A former royal residence with extensive art collections.", Date().addingTimeInterval(86400 * 8), Date().addingTimeInterval(86400 * 9), 2),
                    ("France", "Museums", "Musée Rodin", "A museum dedicated to the works of sculptor Auguste Rodin.", Date().addingTimeInterval(86400 * 9), Date().addingTimeInterval(86400 * 10), 2),

                    // Japan - Museums (5 places)
                    ("Japan", "Museums", "Tokyo National Museum", "The oldest and largest museum in Japan, featuring traditional Japanese art.", Date().addingTimeInterval(86400 * 10), Date().addingTimeInterval(86400 * 11), 3),
                    ("Japan", "Museums", "Kyoto National Museum", "A museum featuring Japanese cultural and historical artifacts.", Date().addingTimeInterval(86400 * 11), Date().addingTimeInterval(86400 * 12), 3),
                    ("Japan", "Museums", "Hiroshima Peace Memorial Museum", "Museum dedicated to the history and aftermath of the Hiroshima bombing.", Date().addingTimeInterval(86400 * 12), Date().addingTimeInterval(86400 * 13), 3),
                    ("Japan", "Museums", "Nara National Museum", "A museum focused on Buddhist art and culture in Nara.", Date().addingTimeInterval(86400 * 13), Date().addingTimeInterval(86400 * 14), 3),
                    ("Japan", "Museums", "Osaka Museum of History", "A museum that explores the history of Osaka, Japan.", Date().addingTimeInterval(86400 * 14), Date().addingTimeInterval(86400 * 15), 3),

                    // Spain - Beach (2 places)
                    ("Spain", "Beach", "Costa Brava", "Beautiful beaches in Costa Brava, Spain.", Date().addingTimeInterval(86400 * 15), Date().addingTimeInterval(86400 * 16), 2),
                    ("Spain", "Beach", "Ibiza Beaches", "Famous beaches on the island of Ibiza.", Date().addingTimeInterval(86400 * 16), Date().addingTimeInterval(86400 * 17), 2),

                    // France - Cities (2 places)
                    ("France", "Cities", "Paris", "The city of lights, full of culture and history.", Date().addingTimeInterval(86400 * 17), Date().addingTimeInterval(86400 * 18), 2),
                    ("France", "Cities", "Nice", "Beautiful city on the French Riviera.", Date().addingTimeInterval(86400 * 18), Date().addingTimeInterval(86400 * 19), 2),
                    
                    // Japan - Museums (1 place)
                    ("Japan", "Museums", "Kyoto Imperial Palace", "The former residence of the imperial family in Kyoto.", Date().addingTimeInterval(86400 * 19), Date().addingTimeInterval(86400 * 20), 1)
                ]
                
                for (country, category, name, details, startDate, endDate, days) in places {
                    let place = Place(context: context)
                    place.country = country
                    place.category = category
                    place.name = name
                    place.details = details
                    place.startDate = startDate
                    place.endDate = endDate
                    place.numberOfDays = Int32(days)
                }
                
                try context.save()
                fetchPlaces()
            }
        } catch {
            print("Error seeding data: \(error.localizedDescription)")
        }
    }
    
    var filteredPlaces: [Place] {
        places.filter { place in
            // Check if the selected date range overlaps with the place's date range
            let placeStartDate = place.startDate ?? Date()
            let placeEndDate = place.endDate ?? Date()

            // Ensure the selected date range overlaps with the place's date range
            let isDateInRange = (selectedStartDate <= placeEndDate) && (selectedEndDate >= placeStartDate)
            
            return place.country == selectedCountry &&
                   place.category == selectedCategory &&
                   isDateInRange
        }
    }

}
