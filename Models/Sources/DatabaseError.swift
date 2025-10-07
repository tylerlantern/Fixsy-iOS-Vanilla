public enum DBError: Error, Equatable {
  public static func == (lhs: DBError, rhs: DBError) -> Bool {
    switch (lhs, rhs) {
    case let (.error(error1), .error(error2)):
      return "\(error1)" == "\(error2)"
    }
  }

  case error(Error)
}
