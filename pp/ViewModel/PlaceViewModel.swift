import SwiftUI
import CoreData

class PlaceViewModel: ObservableObject {
    @Published var selectedCountry: String = "Italy"
    @Published var selectedCategory: String = "Beach"
    @Published var selectedStartDate: Date = Date()
    @Published var selectedEndDate: Date = Date().addingTimeInterval(86400 * 3)

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
        let fetchRequest: NSFetchRequest<Place> = Place.fetchRequest()
        do {
            let allPlaces = try context.fetch(fetchRequest)
            places = allPlaces
        } catch {
            print("Failed to fetch places: \(error)")
        }
    }

    var filteredPlaces: [Place] {
        places.filter { place in
            let placeStartDate = place.startDate ?? Date()
            let placeEndDate = place.endDate ?? Date()

            let isDateInRange = (selectedStartDate <= placeEndDate) && (selectedEndDate >= placeStartDate)
            
            return place.country == selectedCountry &&
                   place.category == selectedCategory &&
                   isDateInRange
        }
    }
    
    func seedInitialData() {
        let fetchRequest: NSFetchRequest<Place> = Place.fetchRequest()
        fetchRequest.fetchLimit = 1
        
        do {
            let count = try context.count(for: fetchRequest)
            if count == 0 {
                let places = [
                    ("Italy", "Beach", "Amalfi Coast Beach", "A stunning beach on the Amalfi Coast.", Date(), Date().addingTimeInterval(86400), 1),
                    // More places...
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
    func adjustEndDateIfNeeded() {
            if selectedEndDate < selectedStartDate {
                selectedEndDate = selectedStartDate
            }
        }

        func adjustStartDateIfNeeded() {
            if selectedStartDate > selectedEndDate {
                selectedStartDate = selectedEndDate
            }
        }

        func calculateNumberOfDays() -> Int {
            return Calendar.current.dateComponents([.day], from: selectedStartDate, to: selectedEndDate).day ?? 0
        }
    }



