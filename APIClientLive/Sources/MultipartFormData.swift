import Foundation
import UIKit

public enum MultipartValue {
  case image(UIImage, MultipartFormImageType),
       images([UIImage], MultipartFormImageType),
       string(String)

  init(_ s: String) {
    self = .string(s)
  }

  init(_ image: UIImage, _ type: MultipartFormImageType) {
    self = .image(image, type)
  }

  init(_ images: [UIImage], _ type: MultipartFormImageType) {
    self = .images(images, type)
  }
}

public enum MultipartFormImageType {
  case jpeg(CGFloat),
       png
  var identifier: String {
    switch self {
    case .jpeg:
      return "jpeg"
    default:
      return "png"
    }
  }
}

public typealias MultipartFormParameters = [String: MultipartValue]

public struct MultipartFormData {
  public var multipartFormParameters: MultipartFormParameters

  public init(
    multipartFormParameters: MultipartFormParameters = .init()
  ) {
    self.multipartFormParameters = multipartFormParameters
  }

  subscript(key: String) -> MultipartValue? {
    get {
      self.multipartFormParameters[key]
    } set {
      self.multipartFormParameters[key] = newValue
    }
  }

  var boundary: String = UUID().uuidString

  var headerValue: String {
    "multipart/form-data; boundary=\(self.boundary)"
  }

  var headerFeild: String {
    "Content-Type"
  }

  private func generateData() -> Data? {
    var data = Data()
    var counter = 0

    for (key, value) in self.multipartFormParameters {
      switch value {
      case let .string(value):
        data.append("\r\n--\(self.boundary)\r\n".data(using: .utf8)!)
        data
          .append(
            "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n"
              .data(using: .utf8)!
          )
        data.append("\(value)".data(using: .utf8)!)
      case let .image(image, type):
        self.appendImageData(
          keyName: key,
          data: &data, type: type, image: image, counter: counter
        )
      case let .images(images, type):
        for im in images {
          self.appendImageData(keyName: key, data: &data, type: type, image: im, counter: counter)
          counter += 1
        }
      }
    }

    data.append("\r\n--\(self.boundary)--\r\n".data(using: .utf8)!)
    return data
  }

  var data: Data? {
    self.generateData()
  }

  func appendImageData(
    keyName: String,
    data: inout Data,
    type: MultipartFormImageType,
    image: UIImage,
    counter: Int
  ) {
    var tempImageData: Data?

    switch type {
    case let .jpeg(compressionQulity):
      tempImageData = image.jpegData(compressionQuality: compressionQulity)
    case .png:
      tempImageData = image.pngData()
    }

    guard let imageData = tempImageData
    else {
      return
    }

    let bcf = ByteCountFormatter()
    bcf.allowedUnits = [.useMB] // optional: restricts the units to MB only
    bcf.countStyle = .file

    let imageName = "image_\(counter)"
    data.append("\r\n--\(self.boundary)\r\n".data(using: .utf8)!)
    data
      .append(
        "Content-Disposition: form-data; name=\"\(keyName)\"; filename=\"\(imageName).\(type.identifier)\"\r\n"
          .data(using: .utf8)!
      )
    data.append("Content-Type: image/\(type.identifier)\r\n\r\n".data(using: .utf8)!)
    data.append(imageData)
  }
}

public extension URLRequest {
  init(url: URL, timeoutInterval: TimeInterval = 20, formData: MultipartFormData) {
    self.init(url: url, timeoutInterval: timeoutInterval)
    self.httpMethod = "POST"
    self.setValue(
      "multipart/form-data; boundary=\(formData.boundary)",
      forHTTPHeaderField: "Content-Type"
    )
    self.setValue("*/*", forHTTPHeaderField: "Accept")
    self.httpBody = formData.data
  }
}
