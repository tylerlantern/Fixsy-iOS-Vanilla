import APIClient
import BannerCenterModule
import CapsulesStackComponent
import CarBrandComponent
import CarBrandsFeature
import LocationManagerClient
import MapKit
import MapPickUpCenterFeature
import Models
import PhotosUI
import SwiftUI
import UIKit

public struct RequestFormView: View {
  enum Field {
    case name
    case phoneCode
    case phoneNumber
  }

  private let maxNumberOfImages: Int = 2

  @Environment(\.apiClient) var apiClient
  @Environment(\.locationManagerClient) var locationManagerClient
  @Environment(\.dismiss) var dismiss
  @EnvironmentObject var banners: BannerCenter

  @FocusState private var focusedField: Field?

  @State private var name: String = ""
  @State private var phoneCode: String = ""
  @State private var phoneNumber: String = ""
  @State private var service: APIUserRoute.Service = .motorcycle

  @State private var coordinateRegion: MKCoordinateRegion
  @State private var hasSetLocationOnce: Bool = false
  @State private var currentUserLocation: CLLocation?

  @State private var showNameError: Bool = false
  @State private var showAddressError: Bool = false
  @State private var showImagesError: Bool = false

  @State private var isSubmiting: Bool = false
  @State private var locationTask: Task<(), Never>?
  @State private var submitTask: Task<(), Never>?

  @State private var selectedItems: [PhotosPickerItem] = []
  @State private var selectedImages: [UIImage] = []
  @State private var selectedCarBrands: [CarBrand] = []
  @State private var pickedUpPin: PinMap?

  @State private var presentedMapPicker: Bool = false
  @State private var presentedCarBrands: Bool = false

  public init(
    coordinateRegion: MKCoordinateRegion = defaultRequestFormRegion()
  ) {
    self._coordinateRegion = .init(initialValue: coordinateRegion)
  }

  public var body: some View {
    NavigationStack {
      GeometryReader { proxy in
        VStack {
          Form {
            basicInfoSection(proxy: proxy)
            addressSection
            imageSection(proxy: proxy)
          }

          Button {
            self.submit()
          } label: {
            HStack(spacing: 8) {
              Spacer()
              if self.isSubmiting {
                ProgressView().tint(.white)
              }
              Text("Save")
                .bold()
                .foregroundColor(.white)
                .padding()
              Spacer()
            }
          }
          .background(Color.blue)
          .padding()
          .disabled(self.isSubmiting)
        }
      }
      .onAppear {
        self.observeLocation()
      }
      .onDisappear {
        self.locationTask?.cancel()
        self.submitTask?.cancel()
      }
      .onChange(of: self.selectedItems) { _, newValue in
        Task {
          self.selectedImages.removeAll()
          for item in newValue {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data)
            {
              self.selectedImages.append(image)
            }
          }
        }
      }
      .toolbar {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
          Button {
            self.dismiss()
          } label: {
            Label("Dismiss", systemImage: "xmark")
              .labelStyle(.iconOnly)
              .frame(width: 44, height: 44)
          }
        }
      }
      .navigationTitle("Request Form")
      .navigationBarTitleDisplayMode(.inline)
      .navigationDestination(
        isPresented: self.$presentedMapPicker,
        destination: {
          MapPickUpCenterView(
            coordinateRegion: self.pickedUpPin.map({
              MKCoordinateRegion(
                center: $0.location.coordinate,
                span: self.coordinateRegion.span
              )
            }) ?? self.coordinateRegion,
            onDone: { region in
              self.coordinateRegion = region
              self.pickedUpPin = PinMap(
                id: UUID().uuidString,
                location: CLLocation(
                  latitude: region.center.latitude,
                  longitude: region.center.longitude
                )
              )
            }
          )
        }
      )
      .navigationDestination(
        isPresented: self.$presentedCarBrands,
        destination: {
          CarBrandsView(
            selectedIds: self.selectedCarBrands.map(\.id),
            onTapSave: { carBrands in
              self.selectedCarBrands = carBrands
              self.presentedCarBrands = false
            }
          )
        }
      )
    }
  }
}

private extension RequestFormView {
  @ViewBuilder
  func basicInfoSection(proxy: GeometryProxy) -> some View {
    Section {
      TextField("Name", text: self.$name)
        .focused(self.$focusedField, equals: .name)
      if self.showNameError {
        Text("Name is required")
          .font(.system(size: 12, weight: .regular, design: .default))
          .foregroundColor(.red)
      }

      HStack {
        Text("Service")
        Spacer()
        Picker("", selection: self.$service) {
          ForEach(APIUserRoute.Service.allCases) { service in
            Text(service.label).tag(service)
          }
        }
        .pickerStyle(.menu)
      }

      VStack(spacing: 8) {
        HStack(spacing: 8) {
          TextField("Code", text: self.$phoneCode)
            .keyboardType(.phonePad)
            .focused(self.$focusedField, equals: .phoneCode)
            .textFieldStyle(.roundedBorder)
            .frame(width: 90)
          TextField("Phone Number", text: self.$phoneNumber)
            .keyboardType(.phonePad)
            .focused(self.$focusedField, equals: .phoneNumber)
            .textFieldStyle(.roundedBorder)
        }
      }

      if self.service == .car {
        ZStack {
          if self.selectedCarBrands.isEmpty {
            Button {
              self.presentedCarBrands = true
            } label: {
              HStack {
                Spacer()
                Text("Click me to select at least one brand.")
                Spacer()
              }
            }
            .buttonStyle(.glass)
          } else {
            CapsulesStackView(items: self.selectedCarBrands) { _, chip in
              CarBrandItemView(
                displayName: chip.displayName,
                isSelected: true
              )
            }
            .frame(maxWidth: proxy.size.width - 32, alignment: .leading)
            .contentShape(Rectangle())
            .onTapGesture {
              self.presentedCarBrands = true
            }
          }
        }
      }
    }
  }

  @ViewBuilder
  var addressSection: some View {
    Section {
      VStack {
        HStack {
          Text("Address")
          Button {
            self.presentedMapPicker = true
          } label: {
            Text("Pick pin point")
              .padding(8)
              .background(Color.blue)
              .foregroundColor(.white)
          }
        }
        if self.showAddressError {
          Text("Please pick pin point")
            .font(.system(size: 12, weight: .regular, design: .default))
            .foregroundColor(.red)
        }
      }

      ZStack {
        Map(
          position: .constant(.region(self.coordinateRegion)),
          interactionModes: []
        ) {
          UserAnnotation()
          ForEach(self.pins) { pin in
            Marker("", coordinate: pin.location.coordinate)
          }
        }
        .aspectRatio(1, contentMode: .fit)
        .disabled(true)

        if self.pins.isEmpty {
          Text("Please pick pin point")
            .font(.title3)
            .bold()
            .foregroundColor(.blue)
        }
      }
    }
  }

  @ViewBuilder
  func imageSection(proxy: GeometryProxy) -> some View {
    Section {
      if self.showImagesError {
        Text("Images are required")
          .font(.system(size: 12, weight: .regular, design: .default))
          .foregroundColor(.red)
      }

      PhotosPicker(
        selection: self.$selectedItems,
        maxSelectionCount: self.maxNumberOfImages,
        matching: .images
      ) {
        HStack {
          Spacer()
          Text("Select Multiple Photos")
          Spacer()
        }
      }
      .buttonStyle(.glass)

      if !self.selectedImages.isEmpty {
        ScrollView(.horizontal) {
          LazyHStack(spacing: 16) {
            ForEach(self.selectedImages, id: \.self) { image in
              let side = imageSize(proxy.size.width, numberOfImages: self.maxNumberOfImages)
              Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: side, height: side)
                .clipped()
            }
          }
        }
      }
    } header: {
      Text("Images")
    }
  }

  var pins: [PinMap] {
    self.pickedUpPin.map({ [$0] }) ?? []
  }

  func imageSize(_ width: CGFloat, numberOfImages: Int) -> CGFloat {
    let totalWidth = width - 64 - CGFloat(numberOfImages - 1) * 16
    return totalWidth / CGFloat(numberOfImages)
  }

  func observeLocation() {
    self.locationTask?.cancel()
    self.currentUserLocation = self.locationManagerClient.location()
    if let location = self.currentUserLocation, !self.hasSetLocationOnce {
      self.hasSetLocationOnce = true
      self.coordinateRegion = .init(
        center: location.coordinate,
        span: .init(latitudeDelta: 0.015, longitudeDelta: 0.015)
      )
    }

    self.locationTask = Task {
      for await locations in self.locationManagerClient.locationStream() {
        guard let location = locations.first else { continue }
        self.currentUserLocation = location
        if !self.hasSetLocationOnce {
          self.hasSetLocationOnce = true
          self.coordinateRegion = .init(
            center: location.coordinate,
            span: .init(latitudeDelta: 0.015, longitudeDelta: 0.015)
          )
        }
      }
    }
  }

  func submit() {
    self.showNameError = self.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    self.showImagesError = self.selectedImages.isEmpty
    self.showAddressError = self.pickedUpPin == nil

    guard
      !self.showNameError,
      !self.showImagesError,
      !self.showAddressError,
      let pin = self.pickedUpPin
    else {
      return
    }

    self.isSubmiting = true
    self.submitTask?.cancel()

    let apiCarBrands = self.selectedCarBrands.map({
      APIUserRoute.CarBrand(
        id: $0.id,
        displayName: $0.displayName
      )
    })

    self.submitTask = Task {
      do {
        _ = try await self.apiClient.call(
          route: .requestForm(
            name: self.name,
            service: self.service,
            phoneCode: self.phoneCode,
            phoneNumber: self.phoneNumber,
            latitude: pin.location.coordinate.latitude,
            longitude: pin.location.coordinate.longitude,
            images: self.selectedImages,
            carBrands: apiCarBrands
          ),
          as: EmptyResponse.self
        )
        self.isSubmiting = false
        self.banners.show(.success, String(localized: "Submitted successfully"))
        self.dismiss()
      } catch {
        self.isSubmiting = false
        if let apiError = error as? APIError {
          self.banners.show(.error, title: apiError.title, body: apiError.body)
          return
        }
        self.banners.show(
          .error,
          title: String(localized: "Something went wrong."),
          body: error.localizedDescription
        )
      }
    }
  }
}

private extension APIUserRoute.Service {
  var label: String {
    switch self {
    case .car:
      return "Car garage"
    case .motorcycle:
      return "Motorcycle garage"
    case .inflatingPoint:
      return "Inflation point"
    case .wash:
      return "Wash station"
    case .patchTire:
      return "Patch tire station"
    }
  }
}

public func defaultRequestFormRegion() -> MKCoordinateRegion {
  MKCoordinateRegion(
    center: .init(latitude: 13.7245599, longitude: 100.492683),
    span: .init(latitudeDelta: 0.05, longitudeDelta: 0.05)
  )
}
