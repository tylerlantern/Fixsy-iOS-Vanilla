import AccessTokenClient
import APIClient
import APIClientLive
import Configs
import ConfigsLive
import DatabaseClient
import DatabaseClientLive
import Models
import ReviewListFeature
import SwiftUI

@main
struct ReviewListFeatureDemoApp: App {
  @State var apiClient: APIClient
  @State var databaseClient: DatabaseClient
  @State var accessTokenClient: AccessTokenClient

  var placeId = 2

  public init() {
    let accessTokenClient = AccessTokenClient.live(
      accessGroup: Configs.live.appGroup.accessGroup,
      service: Configs.live.appGroup.identifier
    )
    self.accessTokenClient = accessTokenClient
    let apiClientLive = APIClient.live(
      url: Configs.live.mobileAPI.hostName,
      getToken: accessTokenClient.accessToken,
      updateToken: accessTokenClient.updateAccessToken
    )
    self.apiClient = apiClientLive
    self.databaseClient = DatabaseClient.liveValue

    try! self.apiClient.override(
      route: .reviewList(
        pageNumber: 1,
        pageSize: 20,
        branchId: 1
      ),
      withResponse: {
        print("HELLO THE RESPONSE")
        // Encode mocks → Data (fallback to empty array JSON if encoding ever fails)
        let data: Data = (try? jsonData(1, 20))!
        let url = URL(string: "https://mock.local/reviewList?page=1&pageSize=20&branchId=1")!
        let res = HTTPURLResponse(
          url: url,
          statusCode: 200,
          httpVersion: "HTTP/1.1",
          headerFields: ["Content-Type": "application/json"]
        )!
        return (data, res)
      }
    )

    try? self.apiClient.override(
      route: .reviewList(
        pageNumber: 2,
        pageSize: 20,
        branchId: 1
      ),
      withResponse: {
        // Encode mocks → Data (fallback to empty array JSON if encoding ever fails)
        let data: Data = (try? jsonData(2, 20))!
        let url = URL(string: "https://mock.local/reviewList?page=1&pageSize=20&branchId=1")!
        let res = HTTPURLResponse(
          url: url,
          statusCode: 200,
          httpVersion: "HTTP/1.1",
          headerFields: ["Content-Type": "application/json"]
        )!
        return (data, res)
      }
    )

    try? self.apiClient.override(
      route: .reviewList(
        pageNumber: 3,
        pageSize: 5,
        branchId: 1
      ),
      withResponse: {
        // Encode mocks → Data (fallback to empty array JSON if encoding ever fails)
        let data: Data = (try? jsonData(3, 5))!
        let url = URL(string: "https://mock.local/reviewList?page=1&pageSize=20&branchId=1")!
        let res = HTTPURLResponse(
          url: url,
          statusCode: 200,
          httpVersion: "HTTP/1.1",
          headerFields: ["Content-Type": "application/json"]
        )!
        return (data, res)
      }
    )
    _ = self.databaseClient.migrate()
  }

  var body: some Scene {
    WindowGroup {
      ReviewListView(
        placeId: 1
      )
      .environment(\.apiClient, self.apiClient)
      .environment(\.accessTokenClient, self.accessTokenClient)
      .environment(\.databaseClient, self.databaseClient)
    }
  }
}

public extension ReviewItemResponse {
  // 20 deterministic items (IDs 1...20)
  static var mocks: [ReviewItemResponse] { mocks(start: 1, count: 20) }

  // unlabeled convenience so you can call `mocks(21, 20)`
  static func mocks(_ start: Int, _ count: Int) -> [ReviewItemResponse] {
    self.mocks(start: start, count: count)
  }

  // main generator: any start + count
  static func mocks(start: Int = 1, count: Int = 20) -> [ReviewItemResponse] {
    guard count > 0 else { return [] }

    let texts = [
      "Quick service and friendly staff.",
      "Great experience! Will come again.",
      "Price was fair. Work done as promised.",
      "Had to wait a bit, but worth it.",
      "Exceptional attention to detail.",
      "Clean shop and clear explanations.",
      "Helped me choose the right service.",
      "Faster than expected, thanks!",
      "Professional and courteous.",
      "Fixed an issue others missed."
    ]
    let names = [
      "Alex Chen", "Maya Patel", "John Smith", "Sara Kim", "Luis García",
      "Emma Johnson", "Noah Brown", "Ava Williams", "Liam Davis", "Olivia Miller"
    ]
    let brands = ["Toyota", "Honda", "Ford", "BMW", "Mercedes", "Mazda", "Nissan", "Audi"]

    let items = (start ..< (start + count)).map { (id: Int) in

      let text = texts[id % texts.count]
      let name = names[id % names.count]
      let profile = "https://i.pravatar.cc/150?img=\((id % 70) + 1)"
      let created = Calendar.current.date(byAdding: .day, value: -id, to: Date()) ?? Date()
      let stars = Double((id % 5) + 1)
      // deterministic 1–2 brands
      let brandCount = (id % 2) + 1
      let carBrands: [CarBrandResponse] = (0 ..< brandCount).map { j in
        let bname = brands[(id + j) % brands.count]
        return CarBrandResponse(
          id: (id * 10) + j,
          displayName: bname
        )
      }
      let imgCount = id % 3
      let imgs: [ImageResponse] = (0 ..< imgCount).map { j in
        ImageResponse(
          id: j + 1,
          url: URL(string: "https://picsum.photos/id/\(id * 10 + j)/600/600")!
        )
      }
      return ReviewItemResponse(
        id: id,
        text: text,
        reviewerName: name,
        reviewerProfileImage: profile,
        createdDate: created,
        givenStar: stars,
        brandCars: carBrands,
        images: imgs
      )
    }
    return items
  }
}

func jsonData(_ start: Int, _ count: Int) throws -> Data {
  let items = ReviewItemResponse.mocks(start, count)

  let pageResponse = PageResponse<ReviewItemResponse>(
    items: items,
    page: start,
    size: count,
    totalpages: 3
  )
  let encoder = JSONEncoder()
  encoder.dateEncodingStrategy = .iso8601
  let str = try String.init(data: encoder.encode(pageResponse), encoding: .utf8)
  print("JSON DATA")
  print(str)
  return try encoder.encode(pageResponse)
}
