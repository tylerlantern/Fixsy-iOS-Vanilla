import CapsulesStackComponent
import CarBrandComponent
import Models
import SwiftUI

struct CarBrandsComponentView: View {
  @State var carBrands: [CarBrand] = []
  let store: CarBrandsStore

  init(
    store: CarBrandsStore
  ) {
    self.store = store
  }

  public var body: some View {
    GeometryReader { proxy in
      ScrollView {
        CapsulesStackView(items: self.store.selections) { selection in
          CarBrandItemView(
            displayName: selection.carBrand.displayName,
            isSelected: selection.$isSelected
          )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .frame(width: proxy.size.width)
      }
    }
  }
}
