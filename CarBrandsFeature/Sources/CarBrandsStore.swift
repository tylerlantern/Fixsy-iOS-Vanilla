import Models
import SwiftUI

@Observable
public class CarBrandsStore {
  @ObservationIgnored
  let selectedIds: Set<Int>

  public init(selectedIds: Set<Int>) {
    self.selectedIds = selectedIds
  }

  public init(selections: [Selection]) {
    self.selectedIds = .init()
    self.selections = selections
  }

  var selections: [Selection] = []

  public struct Selection: Identifiable {
    public var id: Int {
      self.carBrand.id
    }

    let carBrand: CarBrand
    var isSelected: Bool
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

  func toggleSelection(at idx: Int) {
    self.selections[idx].isSelected.toggle()
  }

  func getSelectedBrandCars() -> [CarBrand] {
    self.selections.compactMap({
      if $0.isSelected {
        return $0.carBrand
      }
      return nil
    })
  }
}

extension CarBrandsStore {
  static func shimmer() -> CarBrandsStore {
    CarBrandsStore(
      selections:
      CarBrand.shimmers.map({
        .init(carBrand: $0, isSelected: false)
      })
    )
  }
}
