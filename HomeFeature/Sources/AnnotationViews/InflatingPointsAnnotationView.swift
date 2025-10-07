import MapKit

class InflatingPointsAnnotationView: MKMarkerAnnotationView {
  override var annotation: MKAnnotation? {
    willSet {
      if let _ = newValue as? InflatingPointAnnotation {
        displayPriority = .required
      }
    }
  }
}
