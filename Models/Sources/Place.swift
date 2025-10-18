import Foundation

public struct Place: Equatable, Identifiable {
  public let id: Int
  public let name: String
  public let latitude: Double
  public let longitude: Double
  public let address: String
  public let hasMotorcycleGarage: Bool
  public let hasInflationStation: Bool
  public let hasWashStation: Bool
  public let hasPatchTireStation: Bool
  public let hasCarGarage: Bool
  public let averageRate: Double
  public let carGarage: CarGarage?
  public let openCloseTime: OpenCloseTime
  public let images: [Image]
  public let contributorName: String
  public struct CarGarage: Equatable {
    public let brands: [CarBrand]
    public init(brands: [CarBrand]) {
      self.brands = brands
    }
  }

  public struct OpenCloseTime: Equatable {
    public let mondayOpen: String
    public let mondayClose: String
    public let tuesdayOpen: String
    public let tuesdayClose: String
    public let wednesdayOpen: String
    public let wednesdayClose: String
    public let thursdayOpen: String
    public let thursdayClose: String
    public let fridayOpen: String
    public let fridayClose: String
    public let saturdayOpen: String
    public let saturdayClose: String
    public let sundayOpen: String
    public let sundayClose: String
    public init(
      mondayOpen: String,
      mondayClose: String,
      tuesdayOpen: String,
      tuesdayClose: String,
      wednesdayOpen: String,
      wednesdayClose: String,
      thursdayOpen: String,
      thursdayClose: String,
      fridayOpen: String,
      fridayClose: String,
      saturdayOpen: String,
      saturdayClose: String,
      sundayOpen: String,
      sundayClose: String
    ) {
      self.mondayOpen = mondayOpen
      self.mondayClose = mondayClose
      self.tuesdayOpen = tuesdayOpen
      self.tuesdayClose = tuesdayClose
      self.wednesdayOpen = wednesdayOpen
      self.wednesdayClose = wednesdayClose
      self.thursdayOpen = thursdayOpen
      self.thursdayClose = thursdayClose
      self.fridayOpen = fridayOpen
      self.fridayClose = fridayClose
      self.saturdayOpen = saturdayOpen
      self.saturdayClose = saturdayClose
      self.sundayOpen = sundayOpen
      self.sundayClose = sundayClose
    }

    public static let empty = OpenCloseTime(
      mondayOpen: "", mondayClose: "",
      tuesdayOpen: "", tuesdayClose: "",
      wednesdayOpen: "", wednesdayClose: "",
      thursdayOpen: "", thursdayClose: "",
      fridayOpen: "", fridayClose: "",
      saturdayOpen: "", saturdayClose: "",
      sundayOpen: "", sundayClose: ""
    )
  }

  public struct Image: Equatable, Identifiable {
    public let id: Int
    public let url: URL

    public init(id: Int, url: URL) {
      self.id = id
      self.url = url
    }
  }

  public init(
    id: Int,
    name: String,
    latitude: Double,
    longitude: Double,
    address: String,
    hasMotorcycleGarage: Bool,
    hasInflationStation: Bool,
    hasWashStation: Bool,
    hasPatchTireStation: Bool,
    hasCarGarage: Bool,
    averageRate: Double,
    carGarage: CarGarage?,
    openCloseTime: OpenCloseTime,
    images: [Image],
    contributorName: String
  ) {
    self.id = id
    self.name = name
    self.latitude = latitude
    self.longitude = longitude
    self.address = address
    self.hasMotorcycleGarage = hasMotorcycleGarage
    self.hasInflationStation = hasInflationStation
    self.hasWashStation = hasWashStation
    self.hasPatchTireStation = hasPatchTireStation
    self.hasCarGarage = hasCarGarage
    self.averageRate = averageRate
    self.carGarage = carGarage
    self.openCloseTime = openCloseTime
    self.images = images
    self.contributorName = contributorName
  }
}
