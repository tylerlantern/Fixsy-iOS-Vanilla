import APIClient
import Models
import SwiftUI

extension ReviewFormView {
  func handleOnTapOpeningCarBrandsScree() {
    self.presentedCarBrandsScreen = true
  }

  func validateAndDisplayErrors() -> Bool {
    guard self.rating > 0 else {
      self.showRateError = true
      return false
    }

    if self.hasCarGarage, self.carBrands.isEmpty {
      self.showCarBrandsError = true
      return false
    }
    self.showCarBrandsError = false
    self.showRateError = false
    return true
  }

  func submit() {
    guard self.validateAndDisplayErrors() else {
      return
    }
    let apiCarBrands = self.carBrands.map({
      APIUserRoute.CarBrand(id: $0.id, displayName: $0.displayName)
    })
    self.isSubmiting = true
    self.submitTask?.cancel()
    self.submitTask = Task {
      do {
        let response = try await self.apiClient.call(
          route: .reviewForm(
            branchId: self.placeId,
            text: self.tellStory,
            rate: self.rating,
            images: self.selectedImages,
            carBrands: apiCarBrands
          ),
          as: ReviewItemResponse.self
        )
        let reviewItem = ReviewItem(
          id: response.id,
          text: response.text,
          fullName: response.reviewerName,
          profileImage: response.reviewerProfileImage.flatMap({ URL(string: $0) }),
          givenRate: response.givenStar,
          images: response.images.map({
            ReviewItem.Image(id: $0.id, url: $0.url)
          }),
          createdDate: response.createdDate,
          carBrands: response.brandCars.map({ carBrand in
            .init(id: carBrand.id, displayName: carBrand.displayName)
          })
        )
        _ = try await self.databaseClient.reviewDB.update(
          self.placeId, reviewItem
        )
        banners.show(.success, String(localized: "Submitted successfully"))
        self.dismiss()
      } catch {
        print("ERROR FORM VIEW", error)
        self.isSubmiting = false
        if let apiError = error as? APIError {
          banners.show(.error, title: apiError.title, body: apiError.body)
          return
        }
        banners.show(
          .error,
          title: String(localized: "Something went wrong."),
          body: error.localizedDescription
        )
      }
    }
  }
}
