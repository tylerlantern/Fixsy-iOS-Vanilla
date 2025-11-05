import APIClient
import DatabaseClient
import Models
import SwiftUI

extension CarBrandsView {
  func handleOnDisappear() {
    self.fetchTask?.cancel()
    self.observeTask?.cancel()
  }

  func fetch() {
    self.fetchTask = Task {
      do {
        //				let responseItems =	try await self.apiClient.call(
        //					route: .carBrands,
        //					as: [CarBrandResponse].self
        //				)
        //				let items = responseItems.map({
        //					CarBrand(
        //						id: $0.id,
        //						displayName: $0.displayName
        //					)
        //				})

        try await Task.sleep(nanoseconds: 2_000_000_000)
        try await self.databaseClient.carBrandDB.sync(
          CarBrand.shimmers
        )
      } catch {
        print("Error>>>", error)
        self.display = .fullScreenError
      }
    }
  }

  func observe() {
    self.observeTask?.cancel()
    self.observeTask = Task {
      do {
        for try await carBrands in self.databaseClient.carBrandDB.observe().removeDuplicates() {
          print("CARBRANDS", carBrands.count)
          guard !carBrands.isEmpty else {
            continue
          }
          self.store.updateSelections(
            carBrands: carBrands
          )
        }
      } catch {
        self.display = .fullScreenError
      }
    }
  }
}
