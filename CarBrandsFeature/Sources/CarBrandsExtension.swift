import SwiftUI
import APIClient
import DatabaseClient
import Models

extension CarBrandsView {
	
	func fetch() {
		self.fetchTask = Task {
			do {
				let responseItems =	try await self.apiClient.call(
					route: .carBrands,
					as: [CarBrandResponse].self
				)
				let items = responseItems.map({
					CarBrand(
						id: $0.id,
						displayName: $0.displayName
					)
				})
				try await self.databaseClient.carBrandDB.sync(
					items
				)
			} catch {
				self.display = .fullScreenError
			}
		}
	}
	
	func observe(){
		self.observeTask = Task {
			do {
				for try await carBrands in self.databaseClient.carBrandDB.observe() {
					guard  carBrands.count > 0 else {
						continue;
					}
					self.store.updateSelections(
						carBrands: carBrands
					)
				}
			}catch {
				self.display = .fullScreenError
			}
		}
	}
	
}
