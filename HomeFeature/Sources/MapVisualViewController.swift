import Combine
import MapKit
import Models
import PlaceStore
import UIKit

public class MapVisualViewController: UINavigationController {
  public let channel: MapVisualChannel

  init(channel: MapVisualChannel) {
    self.channel = channel
    super.init(nibName: nil, bundle: nil)
  }

  // MARK: Identifier

  private var task: Task<(), Never>?
  private let map = MKMapView()

  private let CarGarageIdentifier = "CarGarageIdentifier"
  private let MotorcycleGarageIdentifier = "MotorcycleGarageIdentifier"
  private let InflatingPointIdentifier = "InflatingPointIdentifier"
  private let WashStationIdentifier = "WashStationIdentifier"
  private let PatchTireStationIdentifier = "PatchTireStationIdentifier"

  // MARK: Cluster Identifier

  private let ClusterIdentifier = "ClusterIdentifier"
  private let CarClusterIdentifier = "CarClusterIdentifier"
  private let MotorCycleClusterIdentifier = "MotorcycleClusterIdentifier"
  private let InflatingPointClusterIdentifier = "InflatingPointClusterIdentifier"
  private let WashStationClusterIdentifier = "WashStationClusterIdentifier"
  private let PatchTireStationClusterIdentifier = "PatchTireStationClusterIdentifier"

  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override public func viewDidLoad() {
    super.viewDidLoad()

    // MARK: - Register Cluster Annotations

    self.map.register(
      ClusterAnnotationView.self,
      forAnnotationViewWithReuseIdentifier: self.ClusterIdentifier
    )
    self.map.register(
      CarClusterAnnotationView.self,
      forAnnotationViewWithReuseIdentifier: self.CarClusterIdentifier
    )
    self.map.register(
      MotorcycleClusterAnnotationView.self,
      forAnnotationViewWithReuseIdentifier: self.MotorCycleClusterIdentifier
    )
    self.map.register(
      InflatingPointClusterAnnotationView.self,
      forAnnotationViewWithReuseIdentifier: self.InflatingPointClusterIdentifier
    )
    self.map.register(
      WashStationClusterAnnotationView.self,
      forAnnotationViewWithReuseIdentifier: self.WashStationClusterIdentifier
    )
    self.map.register(
      PatchTireClusterAnnotationView.self,
      forAnnotationViewWithReuseIdentifier: self.PatchTireStationClusterIdentifier
    )

    // MARK: Register Annotations

    self.map.register(
      CarGarageAnnotationView.self,
      forAnnotationViewWithReuseIdentifier: self.CarGarageIdentifier
    )

    self.map.register(
      MotorCycleGarageAnnotationView.self,
      forAnnotationViewWithReuseIdentifier: self.MotorcycleGarageIdentifier
    )

    self.map.register(
      InflatingPointsAnnotationView.self,
      forAnnotationViewWithReuseIdentifier: self.InflatingPointIdentifier
    )

    self.map.register(
      WashStationAnnotationView.self,
      forAnnotationViewWithReuseIdentifier: self.WashStationIdentifier
    )
    self.map.register(
      PatchTireAnnotationView.self,
      forAnnotationViewWithReuseIdentifier: self.PatchTireStationIdentifier
    )

    self.map.showsUserLocation = true
    self.layoutUI()
    self.task = Task { [weak self] in
      guard let self else { return }
      for await event in self.channel.eventStream {
        if Task.isCancelled { break }
        switch event {
        case let .places(array):
          await MainActor.run { [weak self] in
            if let annotations = self?.map.annotations, !annotations.isEmpty {
              self?.map.removeAnnotations(annotations)
            }
            self?.map.addAnnotations(
              array.map(MapVisualViewController.mapToAnnotation(place:))
            )
          }
        case let .userRegion(coordinate):
          await MainActor.run { [weak self] in
            self?.map.setRegion(coordinate, animated: true)
          }
        case let .selectedId(id):
          await MainActor.run { [weak self] in
            guard let self else {
              return
            }
            guard let foundedAnnotation = self.map.annotations.first(where: {
              getIdPlaceFromAnnotation($0) == id
            }) else {
              return
            }
            self.map.selectedAnnotations = [foundedAnnotation]
            self.map.region.center = foundedAnnotation.coordinate
          }
        case .requestDeselectedId:
          await MainActor.run { [weak self] in
            guard let self else {
              return
            }
            for annotation in self.map.selectedAnnotations {
              self.map.deselectAnnotation(annotation, animated: true)
            }
          }
        }
      }
    }
  }

  deinit {
    task?.cancel()
    task = nil
  }

  public func layoutUI() {
    self.map.translatesAutoresizingMaskIntoConstraints = false
    self.map.delegate = self
    self.view.addSubview(self.map)
    NSLayoutConstraint.activate([
      self.map.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
      self.map.topAnchor.constraint(
        equalTo: self.view.topAnchor
      ),
      self.map.trailingAnchor.constraint(
        equalTo: self.view.trailingAnchor
      ),
      self.map.bottomAnchor.constraint(
        equalTo: self.view.bottomAnchor
      )
    ])
  }

  func showDetail(id: Int) {
    self.channel.sendAction(
      .didSelect(id)
    )
  }

  static func mapToAnnotation(place: Place) -> MKAnnotation {
    if place.hasCarGarage {
      return CarGarageAnnotation(place: place)
    } else if place.hasMotorcycleGarage {
      return MotorcycleGarageAnnotation(place: place)
    } else if place.hasWashStation {
      return WashStationAnnotation(place: place)
    } else if place.hasPatchTireStation {
      return PatchTireStationAnnotation(place: place)
    } else {
      // MARK: - has inflating point station

      return InflatingPointAnnotation(place: place)
    }
  }
}

extension MapVisualViewController: MKMapViewDelegate {
  public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    if annotation.isKind(of: MKUserLocation.self) {
      return nil
    }

    // MARK: Stations

    if let carGarageAnnotation = annotation as? CarGarageAnnotation {
      let view = mapView.dequeueReusableAnnotationView(
        withIdentifier: self.CarGarageIdentifier,
        for: carGarageAnnotation
      ) as! CarGarageAnnotationView
      let image = HomeFeatureAsset.Images.carIcon.image
      view.glyphImage = image
      view.markerTintColor = HomeFeatureAsset.Colors.carGarage.color
      view.clusteringIdentifier = self.CarClusterIdentifier
      view.displayPriority = .required
      return view
    } else if let motorcycleAnnotation = annotation as? MotorcycleGarageAnnotation {
      let view = mapView.dequeueReusableAnnotationView(
        withIdentifier: self.MotorcycleGarageIdentifier,
        for: motorcycleAnnotation
      ) as! MotorCycleGarageAnnotationView
      let image = HomeFeatureAsset.Images.motorcycleIcon.image
      view.glyphImage = image
      view.markerTintColor = HomeFeatureAsset.Colors.motorcycleGarage.color
      view.clusteringIdentifier = self.MotorCycleClusterIdentifier
      view.displayPriority = .required
      return view
    } else if let inflatingPointAnnotation = annotation as? InflatingPointAnnotation {
      let view = mapView.dequeueReusableAnnotationView(
        withIdentifier: self.InflatingPointIdentifier,
        for: inflatingPointAnnotation
      ) as! InflatingPointsAnnotationView
      view.glyphImage = HomeFeatureAsset.Images.psiIcon.image
      view.markerTintColor = HomeFeatureAsset.Colors.inflationPoint.color
      view.clusteringIdentifier = self.InflatingPointClusterIdentifier
      view.displayPriority = .required
      return view
    } else if let washStationAnnotation = annotation as? WashStationAnnotation {
      let view = mapView.dequeueReusableAnnotationView(
        withIdentifier: self.WashStationIdentifier,
        for: washStationAnnotation
      ) as! WashStationAnnotationView
      view.glyphImage = HomeFeatureAsset.Images.waterDropIcon.image
      view.markerTintColor = HomeFeatureAsset.Colors.washStation.color
      view.clusteringIdentifier = self.WashStationClusterIdentifier
      view.displayPriority = .required
      return view
    } else if let patchTireStationAnnotation = annotation as? PatchTireStationAnnotation {
      let view = mapView.dequeueReusableAnnotationView(
        withIdentifier: self.PatchTireStationIdentifier,
        for: patchTireStationAnnotation
      ) as! PatchTireAnnotationView
      view.glyphImage = HomeFeatureAsset.Images.patchTireIcon.image
      view.markerTintColor = HomeFeatureAsset.Colors.patchTireStation.color
      view.clusteringIdentifier = self.PatchTireStationClusterIdentifier
      view.displayPriority = .required
      return view
    }

    // MARK: Cluster

    else if let clusterAnnotation = annotation as? CarClusterAnnotation {
      let clusterAnnotationView = mapView.dequeueReusableAnnotationView(
        withIdentifier: self.CarClusterIdentifier,
        for: clusterAnnotation
      ) as! CarClusterAnnotationView
      clusterAnnotationView.numberOfChildren = clusterAnnotation.memberAnnotations.count
      clusterAnnotationView.backgroundColor = UIColor.black
      return clusterAnnotationView
    } else if let clusterAnnotation = annotation as? MotorcycleClusterAnnotation {
      let clusterAnnotationView = mapView.dequeueReusableAnnotationView(
        withIdentifier: self.MotorCycleClusterIdentifier,
        for: clusterAnnotation
      ) as! MotorcycleClusterAnnotationView
      clusterAnnotationView.numberOfChildren = clusterAnnotation.memberAnnotations.count
      clusterAnnotationView.backgroundColor = HomeFeatureAsset.Colors.motorcycleGarage.color
      return clusterAnnotationView
    } else if let clusterAnnotation = annotation as? InflatingPointClusterAnnotation {
      let clusterAnnotationView = mapView.dequeueReusableAnnotationView(
        withIdentifier: self.InflatingPointClusterIdentifier,
        for: clusterAnnotation
      ) as! InflatingPointClusterAnnotationView
      clusterAnnotationView.numberOfChildren = clusterAnnotation.memberAnnotations.count
      clusterAnnotationView.backgroundColor = HomeFeatureAsset.Colors.inflationPoint.color
      return clusterAnnotationView
    } else if let clusterAnnotation = annotation as? WashStationClusterAnnotation {
      let clusterAnnotationView = mapView.dequeueReusableAnnotationView(
        withIdentifier: self.WashStationClusterIdentifier,
        for: clusterAnnotation
      ) as! WashStationClusterAnnotationView
      clusterAnnotationView.numberOfChildren = clusterAnnotation.memberAnnotations.count
      clusterAnnotationView.backgroundColor = HomeFeatureAsset.Colors.washStation.color
      return clusterAnnotationView
    } else if let clusterAnnotation = annotation as? PatchTireClusterAnnotation {
      let clusterAnnotationView = mapView.dequeueReusableAnnotationView(
        withIdentifier: self.PatchTireStationClusterIdentifier,
        for: clusterAnnotation
      ) as! PatchTireClusterAnnotationView
      clusterAnnotationView.numberOfChildren = clusterAnnotation.memberAnnotations.count
      clusterAnnotationView.backgroundColor = HomeFeatureAsset.Colors.patchTireStation.color
      return clusterAnnotationView
    }
    return nil
  }

  public func mapView(
    _ mapView: MKMapView,
    clusterAnnotationForMemberAnnotations memberAnnotations: [MKAnnotation]
  ) -> MKClusterAnnotation {
    if let annotations = memberAnnotations as? [MotorcycleGarageAnnotation] {
      return MotorcycleClusterAnnotation(memberAnnotations: annotations)
    } else if let annotations = memberAnnotations as? [InflatingPointAnnotation] {
      return InflatingPointClusterAnnotation(memberAnnotations: annotations)
    } else if let annotations = memberAnnotations as? [WashStationAnnotation] {
      return WashStationClusterAnnotation(memberAnnotations: annotations)
    } else if let annotations = memberAnnotations as? [PatchTireStationAnnotation] {
      return PatchTireClusterAnnotation(memberAnnotations: annotations)
    } else if let annotations = memberAnnotations as? [CarGarageAnnotation] {
      return CarClusterAnnotation(memberAnnotations: annotations)
    }
    return ClusterAnnotation(memberAnnotations: memberAnnotations)
  }

  public func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    switch view {
    case let view as CarGarageAnnotationView:
      if let annotation = view.annotation as? CarGarageAnnotation {
        self.showDetail(id: annotation.id)
      }
    case let view as MotorCycleGarageAnnotationView:
      if let annotation = view.annotation as? MotorcycleGarageAnnotation {
        self.showDetail(id: annotation.id)
      }
    case let view as InflatingPointsAnnotationView:
      if let annotation = view.annotation as? InflatingPointAnnotation {
        self.showDetail(id: annotation.id)
      }
    case let view as WashStationAnnotationView:
      if let annotation = view.annotation as? WashStationAnnotation {
        self.showDetail(id: annotation.id)
      }
    case let view as PatchTireAnnotationView:
      if let annotation = view.annotation as? PatchTireStationAnnotation {
        self.showDetail(id: annotation.id)
      }

    // MARK: - Cluster View
    case let view as CarClusterAnnotationView:
      if let coordinate = view.annotation?.coordinate {
        mapView.deselectAnnotation(view.annotation, animated: false)
        self.channel.sendAction(
          .zoom(to: coordinate)
        )
      }
    case let view as MotorcycleClusterAnnotationView:
      if let coordinate = view.annotation?.coordinate {
        mapView.deselectAnnotation(view.annotation, animated: false)
        self.channel.sendAction(
          .zoom(to: coordinate)
        )
      }
    case let view as InflatingPointClusterAnnotationView:
      if let coordinate = view.annotation?.coordinate {
        self.channel.sendAction(
          .zoom(to: coordinate)
        )
      }
    case let view as WashStationClusterAnnotationView:
      if let coordinate = view.annotation?.coordinate {
        self.channel.sendAction(
          .zoom(to: coordinate)
        )
      }
    case let view as PatchTireClusterAnnotationView:
      if let coordinate = view.annotation?.coordinate {
        self.channel.sendAction(
          .zoom(to: coordinate)
        )
      }
    default:
      break
    }
  }

  public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
    self.channel.sendAction(
      .didChangeCoordiateRegion(mapView.region)
    )
  }

  public func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
    self.channel.sendAction(
      .didDeselect
    )
  }
}

func getIdPlaceFromAnnotation(_ annotation: MKAnnotation) -> Int? {
  if let carGarageAnnotation = annotation as? CarGarageAnnotation {
    return carGarageAnnotation.id
  } else if let inflatingPointAnnotation = annotation as? InflatingPointAnnotation {
    return inflatingPointAnnotation.id
  } else if let motorcycleGarageAnnotation = annotation as? MotorcycleGarageAnnotation {
    return motorcycleGarageAnnotation.id
  } else if let patchTireStationAnnotation = annotation as? PatchTireStationAnnotation {
    return patchTireStationAnnotation.id
  } else if let washStationAnnotation = annotation as? WashStationAnnotation {
    return washStationAnnotation.id
  }
  return nil
}
