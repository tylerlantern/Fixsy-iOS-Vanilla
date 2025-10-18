import MapKit
import Models

public struct MapVisualChannel {
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
    case didSelect(_ placeId: Int)
    case didDeselect
    case didChangeCoordiateRegion(MKCoordinateRegion)
  }

  public let eventStream: AsyncStream<Event>
  public let actionStream: AsyncStream<Action>
  public let sendEvent: (Event) -> ()
  public let sendAction: (Action) -> ()

  public init(
    eventStream: AsyncStream<Event>,
    eventCont: AsyncStream<Event>.Continuation,
    actionStream: AsyncStream<Action>,
    actionCon: AsyncStream<Action>.Continuation
  ) {
    self.eventStream = eventStream
    self.actionStream = actionStream
    self.sendEvent = {
      eventCont.yield($0)
    }
    self.sendAction = {
      actionCon.yield($0)
    }
  }
}
