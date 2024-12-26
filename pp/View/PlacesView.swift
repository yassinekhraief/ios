import SwiftUI

struct PlacesView: View {
    @ObservedObject var viewModel: PlaceViewModel
    
    var body: some View {
        VStack {
            // Dropdown for Country selection
            Picker("Select Country", selection: $viewModel.selectedCountry) {
                ForEach(viewModel.countries, id: \.self) { country in
                    Text(country).tag(country)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding()
            
            // Dropdown for Category selection
            Picker("Select Category", selection: $viewModel.selectedCategory) {
                ForEach(viewModel.categories, id: \.self) { category in
                    Text(category).tag(category)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding()
            
            // Date pickers for start and end dates
            DatePicker("From", selection: $viewModel.selectedStartDate, in: Date()..., displayedComponents: .date)
                .padding()
                .onChange(of: viewModel.selectedStartDate) { newValue in
                    // Ensure "To" date is not earlier than "From" date
                    if viewModel.selectedEndDate < newValue {
                        viewModel.selectedEndDate = newValue
                    }
                }
            
            DatePicker("To", selection: $viewModel.selectedEndDate, in: viewModel.selectedStartDate..., displayedComponents: .date)
                .padding()
                .onChange(of: viewModel.selectedEndDate) { newValue in
                    // Ensure "From" date is not later than "To" date
                    if viewModel.selectedStartDate > newValue {
                        viewModel.selectedStartDate = newValue
                    }
                }
            
            // Calculate the number of days from the selected dates
            let numberOfDays = Calendar.current.dateComponents([.day], from: viewModel.selectedStartDate, to: viewModel.selectedEndDate).day ?? 0
            
            Text("Total Stay: \(numberOfDays) days")
                .font(.subheadline)
                .padding()
            
            // Display filtered places based on selected country, category, and number of days
            List(viewModel.filteredPlaces, id: \.name) { place in
                VStack(alignment: .leading) {
                    Text(place.name ?? "Unknown")
                        .font(.headline)
                    Text(place.details ?? "No details available")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("From: \(place.startDate ?? Date(), formatter: dateFormatter) - To: \(place.endDate ?? Date(), formatter: dateFormatter)")
                        .font(.footnote)
                }
                .padding()
            }
            .onAppear {
                viewModel.fetchPlaces()  // Ensure data is loaded when the view appears
            }
        }
        .navigationTitle("Places")
    }
}

let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    return formatter
}()

struct PlacesView_Previews: PreviewProvider {
    static var previews: some View {
        PlacesView(viewModel: PlaceViewModel(context: PersistenceController.preview.container.viewContext))
    }
}
