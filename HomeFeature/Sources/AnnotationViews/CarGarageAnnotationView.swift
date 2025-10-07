import MapKit

class CarGarageAnnotationView: MKMarkerAnnotationView {
  override var annotation: MKAnnotation? {
    willSet {
      if let _ = newValue as? CarGarageAnnotation {
        displayPriority = .required
      }
    }
  }
}
