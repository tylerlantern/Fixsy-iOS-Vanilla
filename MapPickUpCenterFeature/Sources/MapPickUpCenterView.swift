import LocationManagerClient
import MapKit
import SwiftUI
import UIKit

public struct MapPickUpCenterView: View {
  @Environment(\.locationManagerClient) var locationManagerClient
  @Environment(\.openURL) var openURL
  @Environment(\.dismiss) var dismiss

  @State private var coordinateRegion: MKCoordinateRegion
  @State private var cameraPosition: MapCameraPosition
  @State private var currentUserLocation: CLLocation?
  @State private var locationTask: Task<(), Never>?

  let onDone: (MKCoordinateRegion) -> Void

  public init(
    coordinateRegion: MKCoordinateRegion,
    onDone: @escaping (MKCoordinateRegion) -> Void = { _ in }
  ) {
    self._coordinateRegion = .init(initialValue: coordinateRegion)
    self._cameraPosition = .init(initialValue: .region(coordinateRegion))
    self.onDone = onDone
  }

  public var body: some View {
    GeometryReader { proxy in
      ZStack(alignment: .center) {
        Map(
          position: self.$cameraPosition,
          interactionModes: .all
        ) {
          UserAnnotation()
        }
        .onMapCameraChange(frequency: .continuous) { context in
          self.coordinateRegion = context.region
        }

        Image(systemName: "mappin")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 48, height: 48)
          .foregroundColor(.orange)
          .offset(x: 0, y: -24 - proxy.safeAreaInsets.bottom / 2)
      }
      .overlay(
        alignment: .topTrailing,
        content: {
          Button(
            action: {
              self.centerUserRegion()
            },
            label: {
              Image(systemName: "paperplane.fill")
                .foregroundColor(.blue)
                .frame(width: 36, height: 36)
            }
          )
          .background(Color.white)
          .offset(x: -16, y: 16)
        }
      )
      .edgesIgnoringSafeArea(.bottom)
    }
    .onAppear {
      self.observeLocation()
    }
    .onDisappear {
      self.locationTask?.cancel()
    }
    .navigationTitle(
      String(
        localized: "Pick up the location",
        bundle: .module
      )
    )
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItemGroup(placement: .navigationBarTrailing) {
        Button(
          String(
            localized: "Done",
            bundle: .module
          )
        ) {
          self.onDone(self.coordinateRegion)
          self.dismiss()
        }
      }
    }
  }
}

private extension MapPickUpCenterView {
  func centerUserRegion() {
    let status = self.locationManagerClient.authorizationStatus()
    switch status {
    case .restricted, .denied:
      guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
        return
      }
      self.openURL(settingsURL)
    case .notDetermined:
      self.locationManagerClient.requestWhenInUseAuthorization()
      self.locationManagerClient.requestLocation()
    case .authorizedAlways, .authorizedWhenInUse:
      self.locationManagerClient.requestLocation()
      guard let location = self.currentUserLocation ?? self.locationManagerClient.location() else {
        return
      }
      self.coordinateRegion = .init(
        center: location.coordinate,
        span: self.coordinateRegion.span
      )
      withAnimation(.easeOut) {
        self.cameraPosition = .region(self.coordinateRegion)
      }
    @unknown default:
      break
    }
  }

  func observeLocation() {
    self.locationTask?.cancel()
    self.currentUserLocation = self.locationManagerClient.location()

    self.locationTask = Task {
      for await locations in self.locationManagerClient.locationStream() {
        guard let location = locations.first else { continue }
        self.currentUserLocation = location
      }
    }
  }
}
