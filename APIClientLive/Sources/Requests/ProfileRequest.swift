
import Foundation

public struct ProfileRequest: Codable {
  public let firstName: String
  public let lastName: String
  public let countryCode: String
  public let email: String
  public let mobileNumber: String
  public let gender: String
  public let birthday: String

  public init(
    firstName: String,
    lastName: String,
    countryCode: String,
    email: String,
    mobileNumber: String,
    gender: String,
    birthday: String
  ) {
    self.firstName = firstName
    self.lastName = lastName
    self.countryCode = countryCode
    self.email = email
    self.mobileNumber = mobileNumber
    self.gender = gender
    self.birthday = birthday
  }
}
