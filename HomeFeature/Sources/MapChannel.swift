import MapKit
import Models

public struct MapChannel {
  public enum Event {
    case places([Place])
    case userRegion(MKCoordinateRegion)
    case selectedId(Int?)
    case requestDeselectedId
  }

  public enum Action {
    case viewDidLoad
    case zoom(to: CLLocationCoordinate2D)
    case regionChanged(MKCoordinateRegion)
    case didDeselect
    case didChangeCoordiateRegion(MKCoordinateRegion)
  }

  public let event: AsyncStream<Event>
  public let sendEvent: (Event) -> ()
  public let sendAction: (Action) -> ()

  public init(
    eventChannel: (
      AsyncStream<Event>, AsyncStream<Event>.Continuation
    ),

    actions: AsyncStream<Action>.Continuation
  ) {
    self.event = eventChannel.0
    self.sendEvent = {
      eventChannel.1.yield($0)
    }
    self.sendAction = { actions.yield($0) }
  }
}
