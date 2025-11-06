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
        let responseItems = CarBrand.shimmers
        try await Task.sleep(nanoseconds: 2_000_000_000)
        try await self.databaseClient.carBrandDB.sync(
          responseItems
        )
      } catch {
        self.display = .fullScreenError
      }
    }
  }

  func observe() {
    self.observeTask?.cancel()
    self.observeTask = Task {
      do {
        for try await carBrands in self.databaseClient.carBrandDB.observe().removeDuplicates()
          .filter({ !$0.isEmpty })
        {
          self.display = .render
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
