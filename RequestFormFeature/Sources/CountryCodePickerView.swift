import SwiftUI

struct CountryCodePickerView: View {
  let countries: [CountryCodeData]
  let onSelect: (CountryCodeData) -> Void

  @Environment(\.dismiss) private var dismiss
  @State private var searchText: String = ""

  private var filteredCountries: [CountryCodeData] {
    if searchText.isEmpty {
      return countries
    }
    return countries.filter {
      $0.name.localizedCaseInsensitiveContains(searchText)
        || $0.dialcode.contains(searchText)
    }
  }

  private var suggestedCountry: CountryCodeData {
    CountryCodeDataLoader.defaultCountryCode()
  }

  var body: some View {
    NavigationStack {
      List {
        Section("Suggested") {
          countryRow(suggestedCountry)
        }

        Section("All Countries") {
          ForEach(filteredCountries) { country in
            countryRow(country)
          }
        }
      }
      .searchable(text: $searchText, prompt: "Search country")
      .navigationTitle("Select Country")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            dismiss()
          } label: {
            Label("Close", systemImage: "xmark")
              .labelStyle(.iconOnly)
          }
        }
      }
    }
  }

  @ViewBuilder
  private func countryRow(_ country: CountryCodeData) -> some View {
    Button {
      onSelect(country)
      dismiss()
    } label: {
      HStack(spacing: 12) {
        Image(country.imageName, bundle: .module)
          .resizable()
          .scaledToFit()
          .frame(width: 30, height: 20)

        Text(country.name)
          .foregroundStyle(.primary)

        Spacer()

        Text(country.dialcode)
          .foregroundStyle(.secondary)
      }
    }
  }
}
