struct ListPlacesRequest: Codable {
  let keyword: String
  let services: [String]
  let lat: Double?
  let lng: Double?
  let cursor: Int?
  let distanceCursor: Double?
  let limit: Int
}
