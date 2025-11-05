import AccessTokenClient
import APIClient
import APIClientLive
import CarBrandsFeature
import Configs
import ConfigsLive
import DatabaseClient
import DatabaseClientLive
import Models
import SwiftUI
import TokenModel

@main
struct CarBrandsFeatureDemoApp: App {
  @State var apiClient: APIClient
  @State var databaseClient: DatabaseClient
  @State var accessTokenClient: AccessTokenClient

  public init() {
    let accessTokenClient = AccessTokenClient.live(
      accessGroup: Configs.live.appGroup.accessGroup,
      service: Configs.live.appGroup.identifier
    )
    self.accessTokenClient = accessTokenClient

    let apiClientLive = APIClient.live(
      url: URL(string: "https://google.com")!,
      getToken: {
        TokenModel.Token(
          accessToken: "SalangHeyo",
          refreshToken: "YoyoBoba"
        )
      },
      updateToken: { _ in nil }
    )
    self.apiClient = apiClientLive

    self.databaseClient = DatabaseClient.liveValue
    _ = self.databaseClient.migrate()
    self.apiClient.override(
      route: .carBrands
    ) {
      print("MATCH API")
      return makeJSONOverride(CarBrandResponse.mockAPI)
    }
  }

  var body: some Scene {
    WindowGroup {
      CarBrandsView(selectedIds: [])
        .environment(\.apiClient, self.apiClient)
        .environment(\.accessTokenClient, self.accessTokenClient)
        .environment(\.databaseClient, self.databaseClient)
    }
  }
}

private func makeJSONOverride<T: Encodable>(
  _ value: T,
  statusCode: Int = 200
) -> (data: Data, response: URLResponse) {
  let encoder = JSONEncoder()
  // If your API expects snake_case: uncomment the next line
  // encoder.keyEncodingStrategy = .convertToSnakeCase
  let data = try! encoder.encode(value)
  let response = HTTPURLResponse(
    url: URL(string: "https://google.com")!,
    statusCode: statusCode,
    httpVersion: "HTTP/1.1",
    headerFields: ["Content-Type": "application/json"]
  )!
  return (data, response)
}

extension CarBrandResponse {
  static let mockAPI: [CarBrandResponse] = [
    .init(id: 1, displayName: "Toyota"),
    .init(id: 2, displayName: "Honda"),
    .init(id: 3, displayName: "Nissan"),
    .init(id: 4, displayName: "Mazda"),
    .init(id: 5, displayName: "Mitsubishi"),
    .init(id: 6, displayName: "Suzuki"),
    .init(id: 7, displayName: "Subaru"),
    .init(id: 8, displayName: "Isuzu"),
    .init(id: 9, displayName: "Ford"),
    .init(id: 10, displayName: "Chevrolet"),
    .init(id: 11, displayName: "BMW"),
    .init(id: 12, displayName: "Mercedes-Benz"),
    .init(id: 13, displayName: "Volkswagen"),
    .init(id: 14, displayName: "Hyundai"),
    .init(id: 15, displayName: "Kia"),
    .init(id: 16, displayName: "Lexus"),
    .init(id: 17, displayName: "Volvo"),
    .init(id: 18, displayName: "Porsche"),
    .init(id: 19, displayName: "Audi"),
    .init(id: 20, displayName: "Tesla")
  ]
}
