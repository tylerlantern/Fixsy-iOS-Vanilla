public struct PlaceFilter: Codable, Equatable, Sendable {
  public var showCarGarage: Bool
  public var showMotorcycleGarages: Bool
  public var showInflationPoints: Bool
  public var showWashStations: Bool
  public var showPatchTireStations: Bool

  public init(
    showCarGarage: Bool,
    showMotorcycleGarages: Bool,
    showInflationPoints: Bool,
    showWashStations: Bool,
    showPatchTireStations: Bool
  ) {
    self.showCarGarage = showCarGarage
    self.showMotorcycleGarages = showMotorcycleGarages
    self.showInflationPoints = showInflationPoints
    self.showWashStations = showWashStations
    self.showPatchTireStations = showPatchTireStations
  }

  public static var identity: Self {
    PlaceFilter(
      showCarGarage: true,
      showMotorcycleGarages: true,
      showInflationPoints: true,
      showWashStations: true,
      showPatchTireStations: true
    )
  }
}
