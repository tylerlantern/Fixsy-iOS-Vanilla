import MapKit

class MotorCycleGarageAnnotationView: MKMarkerAnnotationView {
  override var annotation: MKAnnotation? {
    willSet {
      if let _ = newValue as? MotorcycleGarageAnnotation {
        displayPriority = .required
      }
    }
  }
}
