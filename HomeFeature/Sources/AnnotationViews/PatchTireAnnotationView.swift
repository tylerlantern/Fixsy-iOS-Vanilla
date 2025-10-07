import MapKit

class PatchTireAnnotationView: MKMarkerAnnotationView {
  override var annotation: MKAnnotation? {
    willSet {
      if let _ = newValue as? PatchTireAnnotationView {
        displayPriority = .required
      }
    }
  }
}
