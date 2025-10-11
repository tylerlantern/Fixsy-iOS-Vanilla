import Foundation

public struct TokenRequest: Codable {
  let grant_type: String
  let client_id: String
  let client_secret: String
  let username: String
  let password: String
  let registration_id: String
  let device_type: String
  let language: String

  public init(
    grant_type: String = "password",
    client_id: String,
    client_secret: String,
    username: String,
    password: String,
    registration_id: String,
    device_type: String = "ios",
    language: String
  ) {
    self.grant_type = grant_type
    self.client_id = client_id
    self.client_secret = client_secret
    self.username = username
    self.password = password
    self.registration_id = registration_id
    self.device_type = device_type
    self.language = language
  }
}
