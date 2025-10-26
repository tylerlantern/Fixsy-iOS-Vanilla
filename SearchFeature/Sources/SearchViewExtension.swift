import APIClient
import AsyncAlgorithms
import MapKit
import Models
import SwiftUI

extension SearchView {
  func observeLocalData() {
    self.observeFilterTask?.cancel()
    self.transformTask?.cancel()
    self.observeFilterTask = Task {
      for try await filter in self.databaseClient.observePlaceFilter() {
        self.filter = filter
        let placesSeq = self.databaseClient.observeMapData(
          self.filter,
          self.searchText
        ).removeDuplicates()
        let locSeq = self.locationManagerClient.locationStream()
        self.observePlaceTask?.cancel()
        self.observePlaceTask = Task {
          for try await(places, locs) in combineLatest(placesSeq, locSeq) {
            self.transformTask?.cancel()
            self.transformTask = Task.detached {
              let sortedItems = sortItesmByNearest(
                locs,
                places: places
              )
              await MainActor.run {
                self.items = sortedItems
              }
            }
          }
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

  func searchTextChanged() {
    self.searchTask?.cancel()
    self.searchTask = Task {
      try await Task.sleep(nanoseconds: 300_000_000)
      self.observeLocalData()
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

public func haversine(
  lat1: Double,
  lon1: Double,
  lat2: Double,
  lon2: Double
) -> Double {
  let radius: Double = 6_371
  let latDelta = (lat2 - lat1) * .pi / 180
  let lonDelta = (lon2 - lon1) * .pi / 180

  let a = sin(latDelta / 2) * sin(latDelta / 2) +
    cos(lat1 * .pi / 180) * cos(lat2 * .pi / 180) *
    sin(lonDelta / 2) * sin(lonDelta / 2)

  let c = 2 * atan2(sqrt(a), sqrt(1 - a))
  return radius * c
}

public func sortItesmByNearest(
  _ locs: [CLLocation],
  places: [Place]
) -> [Item] {
  let sortedItems = places.map({ place in
    guard let userLoc = locs.last else {
      return Item(
        id: place.id,
        name: place.name,
        image: Item.parseImage(place),
        service: Item.parseService(place),
        address: place.address,
        distance: nil
      )
    }
    let distance = haversine(
      lat1: userLoc.coordinate.latitude,
      lon1: userLoc.coordinate.longitude,
      lat2: place.latitude,
      lon2: place.longitude
    )
    return Item(
      id: place.id,
      name: place.name,
      image: Item.parseImage(place),
      service: Item.parseService(place),
      address: place.address,
      distance: distance
    )
  })
  .sorted { item1, item2 in
    guard let distance1 = item1.distance,
          let distance2 = item2.distance
    else {
      return false
    }
    return distance1 < distance2
  }
  return sortedItems
}
