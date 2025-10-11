import Foundation

public struct UploadProfileImageRequest: Codable {
  private let picture: String

  public init(base64Image: String) {
    self.picture = "data:image/jpeg;base64,\(base64Image)"
  }
}
