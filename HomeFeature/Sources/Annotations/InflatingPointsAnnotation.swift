import MapKit
import UIKit
import Models


public class InflatingPointAnnotation: NSObject, MKAnnotation {
  public let coordinate: CLLocationCoordinate2D
  public let id: Int
  public init(place: Place) {
    self.coordinate = CLLocationCoordinate2D(
      latitude: place.latitude,
      longitude: place.longitude
    )
    self.id = place.id
  }
}
