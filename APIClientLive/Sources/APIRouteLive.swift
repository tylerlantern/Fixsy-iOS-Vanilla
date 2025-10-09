import APIClient
import Configs
import Foundation
import Model
import Overture

extension APIRoute {
  func urlRequest(url: URL) -> URLRequest {
    switch self {
    case .login:
      fatalError()
    case .signUp:
      fatalError()
    case .mapData:
      return update(
        URLRequest(
          url: url
            .appendingPathComponent("mapdata")
            .appendingPathComponent("serviceplaces")
        ),
        setHeader(name: "version", value: "1.1"),
        mut(\.httpMethod, .get),
        jsonContentType
      )
    case let .socialSignIn(
      token: token,
      provider: provider
    ):
      return update(
        URLRequest(
          url: url
            .appendingPathComponent("auth")
            .appendingPathComponent("socialsignin")
        ),
        setHeader(name: "version", value: "1.0"),
        mut(\.httpMethod, .post),
        jsonBody(
          body: SocialSignInRequest(
            token: token,
            provider: provider
          )
        ),
        jsonContentType
      )
    case let .reviewList(pageNumber: pageNumber, pageSize: pageSize, branchId: branchId):
      var queryItems = [URLQueryItem]()
      queryItems.append(.init(name: "pageNumber", value: "\(pageNumber)"))
      queryItems.append(.init(name: "pageSize", value: "\(pageSize)"))
      queryItems.append(.init(name: "branchId", value: "\(branchId)"))
      return update(
        URLRequest(
          url: url
            .appendingPathComponent("review")
            .appendingQueries(queryItems)
        ),
        setHeader(name: "version", value: "1.0"),
        mut(\.httpMethod, .get),
        jsonContentType
      )
		case let .refreshToken(
			accessToken,
			refreshToken
		):
      return update(
        URLRequest(
          url: url
            .appendingPathComponent("auth/refreshtoken")
        ),
        setHeader(name: "version", value: "1.0"),
        mut(\.httpMethod, .post),
        jsonBody(
          body: RefreshTokenRequest(
            accessToken: accessToken,
            refreshToken: refreshToken
          )
        ),
        jsonContentType
      )
    case let .socialSignin(token: token, provider: provider):
      return update(
        URLRequest(
          url: url
            .appendingPathComponent("auth")
            .appendingPathComponent("socialsignin")
        ),
        mut(\.httpMethod, .post),
        setHeader(name: "version", value: "1.0"),
        jsonBody(
          body:
          SocialSignInRequest(
            token: token,
            provider: provider
          )
        ),
        jsonContentType
      )
    case let .socialSignup(
      token: token,
      provider: provider,
      firstname: firstname,
      lastname: lastname,
      username: username,
      picture: picture
    ):
      return update(
        URLRequest(
          url: url
            .appendingPathComponent("auth")
            .appendingPathComponent("socialsignup")
        ),
        mut(\.httpMethod, .post),
        setHeader(name: "version", value: "1.0"),
        jsonBody(
          body:
          SocialSignupRequest(
            token: token,
            provider: provider,
            firstname: firstname,
            lastname: lastname,
            username: username,
            picture: picture ?? ""
          )
        ),
        jsonContentType
      )
    }
  }
}

extension APIUserRoute {
  func urlRequest(url: URL, token: Token) -> URLRequest {
    switch self {
    case let .editName(firstName: firstName, lastName: lastName):
      return update(
        URLRequest(
          url: url
            .appendingPathComponent("profile/editname")
        ),
        mut(\.httpMethod, .post),
        authorizationHeader(accessToken: token.accessToken),
        jsonBody(body: EditingNameRequest(firstName: firstName, lastName: lastName)),
        jsonContentType
      )
    case .logout:
      return update(
        URLRequest(
          url: url
            .appendingPathComponent("auth/revoke")
        ),
        setHeader(name: "version", value: "1.0"),
        mut(\.httpMethod, .post),
        authorizationHeader(accessToken: token.accessToken),
        jsonContentType
      )
    case .userProfile:
      return update(
        URLRequest(
          url: url
            .appendingPathComponent("profile")
        ),
        authorizationHeader(accessToken: token.accessToken),
        mut(\.httpMethod, .get)
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

      return update(
        URLRequest(
          url: url
            .appendingPathComponent("requestform")
            .appendingPathComponent("create"),
          formData: multipartFormData
        ),
        setHeader(name: "version", value: "1.1"),
        authorizationHeader(accessToken: token.accessToken),
        mut(\.httpMethod, .post)
      )
    case .carBrands:
      return update(
        URLRequest(
          url: url
            .appendingPathComponent("brand")
            .appendingPathComponent("car")
        ),
        authorizationHeader(accessToken: token.accessToken),
        mut(\.httpMethod, .get)
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
        parameters["files"] = .images(images, .jpeg(0.75))
      }
      let carBrandIds = carBrands
        .map(\.id)
        .map(String.init)
        .joined(separator: ",")
      if !carBrandIds.isEmpty {
        parameters["brandOfCarIds"] = .string(carBrandIds)
      }
      let multipartFormData = MultipartFormData(multipartFormParameters: parameters)
      return update(
        URLRequest(
          url: url
            .appendingPathComponent("review")
            .appendingPathComponent("create"),
          formData: multipartFormData
        ),
        setHeader(name: "version", value: "1.1"),
        authorizationHeader(accessToken: token.accessToken),
        mut(\.httpMethod, .post)
      )
    case .delete:
      return update(
        URLRequest(
          url: url
            .appendingPathComponent("auth/delete")
        ),
        setHeader(name: "version", value: "1.0"),
        mut(\.httpMethod, .post),
        authorizationHeader(accessToken: token.accessToken),
        jsonContentType
      )
    }
  }
}

let guaranteeHeaders: (inout URLRequest) -> () =
  mver(\URLRequest.allHTTPHeaderFields) { $0 = $0 ?? [:] }

func setHeader(name: String, value: String?) -> (inout URLRequest) -> () {
  concat(
    guaranteeHeaders,
    { $0.allHTTPHeaderFields?[name] = value }
  )
}

func authorizationHeader(accessToken: String) -> (inout URLRequest) -> () {
  setHeader(name: "Authorization", value: "Bearer \(accessToken)")
}

let jsonContentType = setHeader(name: "Content-Type", value: "application/json")

func method(_ method: String) -> (inout URLRequest) -> () {
  { urlRequest in urlRequest.httpMethod = method }
}

func jsonBody<T: Encodable>(body: T) -> (inout URLRequest) -> () {
  mut(\URLRequest.httpBody, try? JSONEncoder().encode(body))
}

typealias HTTPMethod = String

extension HTTPMethod {
  static var get: Self = "GET"
  static var post: Self = "POST"
  static var put: Self = "PUT"
  static var delete: Self = "DELETE"
}

func genderValue(gender: Gender) -> String {
  switch gender {
  case .male:
    return "Male"
  case .female:
    return "Female"
  case .other:
    return "other"
  case .none:
    return ""
  }
}

func dateValue(date: Date?) -> String {
  guard let date = date else { return "" }
  let formatter = DateFormatter()
  formatter.calendar = Calendar(identifier: .gregorian)
  formatter.dateFormat = "MM/dd/yyyy"
  formatter.locale = Locale(identifier: "en_US")
  return formatter.string(from: date)
}
