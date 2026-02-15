import APIClient
import Models
import ReviewListFeature
import SwiftUI

extension SearchView {
  func buildAndInitializeStore() {
    let apiClient = self.apiClient
    let locationManagerClient = self.locationManagerClient
    let searchText = self.searchText
    let pageSize = self.pageSize
    let services = self.filter.toServiceParams()

    let store = InfiniteListStore<Item, DistanceCursor, CursorPlaceResponse>(
      fetchClosure: { cursor in
        let loc = locationManagerClient.location()
        return try await apiClient.call(
          route: .mapDataList(
            keyword: searchText,
            services: services,
            lat: loc?.coordinate.latitude,
            lng: loc?.coordinate.longitude,
            cursor: cursor?.cursor,
            distanceCursor: cursor?.distanceCursor,
            limit: pageSize
          ),
          as: CursorPlaceResponse.self
        )
      },
      parseResponse: { response in
        let items = response.items.map { place in
          mapPlaceResponseToItem(place)
        }
        let nextCursor: DistanceCursor? =
          if let next = response.nextCursor {
            DistanceCursor(
              cursor: next,
              distanceCursor: response.nextDistanceCursor
            )
          } else {
            nil
          }
        return (items, nextCursor)
      }
    )
    self.listStore = store
    self.storeId = UUID()
  }

  func triggerSearch() {
    self.searchTask?.cancel()
    self.listStore?.handleOnDisappear()
    self.buildAndInitializeStore()
  }

  func debouncedSearch() {
    self.searchTask?.cancel()
    self.searchTask = Task {
      try await Task.sleep(nanoseconds: 300_000_000)
      self.triggerSearch()
    }
  }

  func observeFilterChanges() {
    self.observeFilterTask?.cancel()
    self.observeFilterTask = Task {
      var isFirst = true
      for try await filter in self.databaseClient.observePlaceFilter() {
        self.filter = filter
        if isFirst {
          isFirst = false
        } else {
          self.triggerSearch()
        }
      }
    }
  }

  func observeUserProfile() {
    observeLocalUserTask?.cancel()
    observeLocalUserTask = Task {
      for try await user in self.databaseClient.userProfileDB.observeUserProfile() {
        self.profileURL = user?.pictureURL
      }
    }
  }

  func onTapAvartarProfile() {
    fetchLocalToken?.cancel()
    fetchLocalToken = Task {
      do {
        guard let _ = try await self.accessTokenClient.accessToken()
        else {
          self.presentedSocialSignInScreen = true
          return
        }
        self.presentedUserProfileScreen = true
      } catch {
        if let apiError = error as? APIError {
          self.banners.show(
            .error,
            title: apiError.title,
            body: apiError.body
          )
        }
      }
    }
  }
}

extension PlaceFilter {
  func toServiceParams() -> [String] {
    var services: [String] = []
    if self.showCarGarage { services.append("cargarage") }
    if self.showMotorcycleGarages { services.append("motorcycle") }
    if self.showInflationPoints { services.append("inflatingpoint") }
    if self.showWashStations { services.append("washstation") }
    if self.showPatchTireStations { services.append("patchtirestation") }
    return services
  }
}

func mapPlaceResponseToItem(
  _ place: PlaceResponse
) -> Item {
  let modelPlace = Place(
    id: place.id,
    name: place.name,
    latitude: place.latitude,
    longitude: place.longitude,
    address: place.address,
    hasMotorcycleGarage: place.hasMotorcycleGarage,
    hasInflationStation: place.hasInflationStation,
    hasWashStation: place.hasWashStation,
    hasPatchTireStation: place.hasPatchTireStation,
    hasCarGarage: place.hasCarGarage,
    averageRate: place.averageRate,
    carGarage: nil,
    openCloseTime: .empty,
    images: [],
    contributorName: place.contributorName
  )
  return Item(
    id: place.id,
    name: place.name,
    image: Item.parseImage(modelPlace),
    service: Item.parseService(modelPlace),
    address: place.address,
    displayDistance: place.displayDistance
  )
}
