import Foundation

struct CountryCodeData: Codable, Identifiable, Equatable {
  let code: String
  let name: String
  let dialcode: String
  let imageName: String

  var id: String { code }
}

enum CountryCodeDataLoader {
  static func loadCountryCodes() -> [CountryCodeData] {
    guard
      let url = Bundle.module.url(
        forResource: "CountryCodes",
        withExtension: "json"
      ),
      let data = try? Data(contentsOf: url),
      let models = try? JSONDecoder().decode([CountryCodeData].self, from: data)
    else {
      return []
    }
    return models.sorted { $0.name < $1.name }
  }

  static func defaultCountryCode(locale: Locale = .current) -> CountryCodeData {
    let all = loadCountryCodes()
    let regionCode = locale.region?.identifier.lowercased()
    if let regionCode,
       let match = all.first(where: { $0.code == regionCode }) {
      return match
    }
    return all.first(where: { $0.code == "us" })
      ?? CountryCodeData(code: "us", name: "United States", dialcode: "+1", imageName: "flag_united_states_of_america")
  }
}
