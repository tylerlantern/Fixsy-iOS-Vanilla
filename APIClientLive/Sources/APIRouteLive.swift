import APIClient
import Foundation
import TokenModel

extension APIRoute {
  func urlRequest(url: URL) -> URLRequest {
    switch self {
    case .login:
      fatalError()
    case .signUp:
      fatalError()
    case .mapData:
      return url
        .appendingPathComponent("mapdata")
        .appendingPathComponent("serviceplaces")
        .makeAnonymousURLRequest(
          version: "1.1",
          method: .get
        )
    case let .mapDataList(keyword, services, lat, lng, cursor, distanceCursor, limit):
      return url
        .appendingPathComponent("mapdata")
        .appendingPathComponent("list")
        .makeAnonymousURLRequest(
          version: "1.0",
          method: .post(
            ListPlacesRequest(
              keyword: keyword,
              services: services,
              lat: lat,
              lng: lng,
              cursor: cursor,
              distanceCursor: distanceCursor,
              limit: limit
            )
          )
        )
    case let .socialSignIn(
      token: token,
      provider: provider
    ):
      return url
        .appendingPathComponent("mapdata")
        .appendingPathComponent("serviceplaces")
        .makeAnonymousURLRequest(
          version: "1.1",
          method: .post(
            SocialSignInRequest(
              token: token,
              provider: provider
            )
          )
        )
    case let .reviewList(pageNumber: pageNumber, pageSize: pageSize, branchId: branchId):
      var queryItems = [URLQueryItem]()
      queryItems.append(.init(name: "pageNumber", value: "\(pageNumber)"))
      queryItems.append(.init(name: "pageSize", value: "\(pageSize)"))
      queryItems.append(.init(name: "branchId", value: "\(branchId)"))
      let url = url
        .appendingPathComponent("review")
        .appendingQueries(queryItems)
      return url.makeAnonymousURLRequest(
        version: "1.0",
        method: .get
      )
    case let .refreshToken(
      accessToken,
      refreshToken
    ):
      return url
        .appendingPathComponent("auth/refreshtoken")
        .makeAnonymousURLRequest(
          version: "1.0",
          method: .post(
            RefreshTokenRequest(
              accessToken: accessToken,
              refreshToken: refreshToken
            )
          )
        )
    case let .socialSignin(token: token, provider: provider):
      return url
        .appendingPathComponent("auth")
        .appendingPathComponent("socialsignin")
        .makeAnonymousURLRequest(
          version: "1.0",
          method: .post(
            SocialSignInRequest(
              token: token,
              provider: provider
            )
          )
        )
    case let .socialSignup(
      token: token,
      provider: provider,
      firstname: firstname,
      lastname: lastname,
      username: username,
      picture: picture
    ):
      return url
        .appendingPathComponent("auth")
        .appendingPathComponent("socialsignup")
        .makeAnonymousURLRequest(
          version: "1.0",
          method: .post(
            SocialSignupRequest(
              token: token,
              provider: provider,
              firstname: firstname,
              lastname: lastname,
              username: username,
              picture: picture ?? ""
            )
          )
        )
    }
  }
}

extension APIUserRoute {
  func urlRequest(url: URL, token: Token) -> URLRequest {
    switch self {
    case let .editName(firstName: firstName, lastName: lastName):
      return url
        .appendingPathComponent("profile/editname")
        .makeAuthorizationURLRequest(
          token: token,
          version: nil,
          method: .post(EditingNameRequest(firstName: firstName, lastName: lastName))
        )
    case .logout:
      return url
        .appendingPathComponent("auth/revoke")
        .makeAuthorizationURLRequest(
          token: token,
          version: nil,
          method: .post(EmptyRequest())
        )
    case .userProfile:
      return url
        .appendingPathComponent("profile")
        .makeAuthorizationURLRequest(
          token: token,
          version: nil,
          method: .get
        )
    case let .requestForm(
      name,
      service,
      phoneCode,
      phoneNumber,
      latitude,
      longitude,
      images,
      carBrands
    ):

      var parameters: MultipartFormParameters = [
        "name": .string(name),
        "service": .string(service.postValue),
        "latitude": .string(String(latitude)),
        "longitude": .string(String(longitude)),
        "files": .images(images, .jpeg(0.5))
      ]

      if !phoneCode.isEmpty, !phoneNumber.isEmpty {
        parameters["phoneCode"] = .string(phoneCode)
        parameters["phoneNumber"] = .string(phoneNumber)
      }

      let carBrandIds = carBrands
        .map(\.id)
        .map(String.init)
        .joined(separator: ",")

      if !carBrandIds.isEmpty {
        parameters["BrandOfCarIds"] = .string(carBrandIds)
      }

      let multipartFormData = MultipartFormData(multipartFormParameters: parameters)
      var urlRequest = URLRequest(
        url: url
          .appendingPathComponent("requestform")
          .appendingPathComponent("create"),
        formData: multipartFormData
      )
      urlRequest.httpMethod = .post
      setHeader(name: "version", value: "1.1")(&urlRequest)
      authorizationHeader(
        accessToken: token.accessToken
      )(&urlRequest)
      return urlRequest
    case .carBrands:
      return url
        .appendingPathComponent("brand")
        .appendingPathComponent("car")
        .makeAuthorizationURLRequest(
          token: token
        )
    case let .reviewForm(
      branchId: branchId,
      text: text,
      rate: rate,
      images: images,
      carBrands: carBrands
    ):
      var parameters: MultipartFormParameters = [
        "branchId": .string(String(branchId)),
        "rate": .string(String(rate))
      ]
      if !text.isEmpty {
        parameters["text"] = .string(text)
      }
      if !images.isEmpty {
        parameters["files"] = .images(images, .jpeg(0.50))
      }
      let carBrandIds = carBrands
        .map(\.id)
        .map(String.init)
        .joined(separator: ",")
      if !carBrandIds.isEmpty {
        parameters["brandOfCarIds"] = .string(carBrandIds)
      }
      let multipartFormData = MultipartFormData(multipartFormParameters: parameters)
      var urlRequest = URLRequest(
        url: url
          .appendingPathComponent("review")
          .appendingPathComponent("create"),
        formData: multipartFormData
      )
      urlRequest.httpMethod = .post
      authorizationHeader(
        accessToken: token.accessToken
      )(&urlRequest)
      return urlRequest
    case .delete:
      return url
        .appendingPathComponent("auth")
        .appendingPathComponent("delete")
        .makeAuthorizationURLRequest(
          token: token,
          version: "1.0",
          method: .post(EmptyRequest())
        )
    }
  }
}

public struct EmptyBody: Codable { public init() {} }
public typealias HttpMethodNoBody = HttpMethod<EmptyBody>

extension URL {
  // Overload for no-body methods
  func makeAnonymousURLRequest(
    version: String?,
    method: HttpMethodNoBody = .get // default GET without body
  ) -> URLRequest {
    makeCommonRequest(url: self, version: version, method: method)
  }

  func makeAnonymousURLRequest<Body: Encodable>(
    version: String?,
    method: HttpMethod<Body>
  ) -> URLRequest {
    makeCommonRequest(
      url: self,
      version: version,
      method: method
    )
  }

  func makeAuthorizationURLRequest(
    token: Token,
    version: String? = nil,
    method: HttpMethodNoBody = .get
  ) -> URLRequest {
    var urlRequest = makeCommonRequest(
      url: self,
      version: version,
      method: method
    )
    authorizationHeader(
      accessToken: token.accessToken
    )(&urlRequest)
    return urlRequest
  }

  func makeAuthorizationURLRequest<Body: Encodable>(
    token: Token,
    version: String?,
    method: HttpMethod<Body>
  ) -> URLRequest {
    var urlRequest = makeCommonRequest(
      url: self,
      version: version,
      method: method
    )
    authorizationHeader(
      accessToken: token.accessToken
    )(&urlRequest)
    return urlRequest
  }

}

func makeCommonRequest<Body: Encodable>(
  url: URL,
  version: String?,
  method: HttpMethod<Body>?
) -> URLRequest {
  var urlRequest = URLRequest(
    url: url
  )
  if let version = version {
    setHeader(name: "version", value: version)(&urlRequest)
  }
  if let method = method,
     let body = method.extractBody
  {
    urlRequest.httpMethod = method.httpMethod
    let encodedBody = try? JSONEncoder().encode(body)
    urlRequest.httpBody = encodedBody
  }
  jsonContentType(&urlRequest)
  return urlRequest
}

func setHeader(name: String, value: String?) -> (inout URLRequest) -> () {
  { (urlRequest: inout URLRequest) in
    if urlRequest.allHTTPHeaderFields == nil {
      urlRequest.allHTTPHeaderFields = [:]
    }
    urlRequest.allHTTPHeaderFields?[name] = value
  }
}

func setMultipartFormData(
  _ formData: MultipartFormData
) -> (inout URLRequest) -> () {
  { urlRequest in
    urlRequest.httpMethod = "POST"
    urlRequest.setValue(
      "multipart/form-data; boundary=\(formData.boundary)",
      forHTTPHeaderField: "Content-Type"
    )
    urlRequest.setValue("*/*", forHTTPHeaderField: "Accept")
    urlRequest.httpBody = formData.data
  }
}

func authorizationHeader(accessToken: String) -> (inout URLRequest) -> () {
  setHeader(name: "Authorization", value: "Bearer \(accessToken)")
}

let jsonContentType = setHeader(name: "Content-Type", value: "application/json")

func method(_ method: String) -> (inout URLRequest) -> () {
  { urlRequest in urlRequest.httpMethod = method }
}

typealias HTTPMethod = String

extension HTTPMethod {
  static var get: Self = "GET"
  static var post: Self = "POST"
  static var put: Self = "PUT"
  static var delete: Self = "DELETE"
}

func dateValue(date: Date?) -> String {
  guard let date = date else { return "" }
  let formatter = DateFormatter()
  formatter.calendar = Calendar(identifier: .gregorian)
  formatter.dateFormat = "MM/dd/yyyy"
  formatter.locale = Locale(identifier: "en_US")
  return formatter.string(from: date)
}
