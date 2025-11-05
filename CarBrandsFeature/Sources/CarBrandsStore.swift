import Models
import SwiftUI

@Observable
public class CarBrandsStore {
  @ObservationIgnored
  let selectedIds: Set<Int>

  public init(selectedIds: Set<Int>) {
    self.selectedIds = selectedIds
  }

  var selections: [Selection] = []

  public struct Selection: Identifiable {
    public var id: Int {
      self.carBrand.id
    }

    let carBrand: CarBrand
    @State var isSelected: Bool
  }

  func updateSelections(carBrands: [CarBrand]) {
    let selections = carBrands.map({
      let isSelected = self.selectedIds.contains($0.id)
      return Selection(
        carBrand: $0,
        isSelected: isSelected
      )
    })
    self.selections = selections
  }
}

extension CarBrandsStore {
  static func shimmer() -> CarBrandsStore {
    CarBrandsStore(selectedIds: [])
  }
}
