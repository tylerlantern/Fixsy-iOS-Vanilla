import MapKit

class WashStationAnnotationView: MKMarkerAnnotationView {
  override var annotation: MKAnnotation? {
    willSet {
      if let _ = newValue as? WashStationAnnotationView {
        displayPriority = .required
      }
    }
  }
}
