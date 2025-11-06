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
        CapsulesStackView(items: self.store.selections) { idx, item in
          CarBrandItemView(
            displayName: item.carBrand.displayName,
            isSelected: item.isSelected,
            onTap: {
              self.store.toggleSelection(at: idx)
            }
          )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .frame(width: proxy.size.width)
      }
    }
  }
}
