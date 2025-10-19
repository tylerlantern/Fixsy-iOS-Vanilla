public enum OAuthProvider: Int, Codable, Equatable {
  case facebook = 1
  case google = 2
  case apple = 3
}

public struct OAuthProviderSignInRequest: Codable {
  let oauth_provider: OAuthProvider
  let oauth_provider_id: String
  let oauth_provider_token: String
  let client_id: String
  let client_secret: String
  let registration_id: String
  var device_type: String = "ios"

  public init(
    oauth_provider: OAuthProvider,
    oauth_provider_id: String,
    oauth_provider_token: String,
    client_id: String,
    client_secret: String,
    registration_id: String
  ) {
    self.oauth_provider = oauth_provider
    self.oauth_provider_id = oauth_provider_id
    self.oauth_provider_token = oauth_provider_token
    self.client_id = client_id
    self.client_secret = client_secret
    self.registration_id = registration_id
  }
}

public struct OAuthProviderSignUpRequest: Codable {
  let oauthProvider: OAuthProvider
  let oauthProviderId: String
  let oauthProviderToken: String
  let clientId: String
  let clientSecret: String
  let registrationId: String
  var deviceType: String = "ios"
  let username: String
  let firstName: String
  let lastName: String
  let deviceLanguageCode: String

  public init(
    oauthProvider: OAuthProvider,
    oauthProviderId: String,
    oauthProviderToken: String,
    clientId: String,
    clientSecret: String,
    registrationId: String,
    username: String,
    firstName: String,
    lastName: String,
    deviceLanguageCode: String
  ) {
    self.oauthProvider = oauthProvider
    self.oauthProviderId = oauthProviderId
    self.oauthProviderToken = oauthProviderToken
    self.clientId = clientId
    self.clientSecret = clientSecret
    self.registrationId = registrationId
    self.username = username
    self.firstName = firstName
    self.lastName = lastName
    self.deviceLanguageCode = deviceLanguageCode
  }
}
