import Foundation

final class RateLimiter {
	private(set) var timestamps: [Date] = []
	private let limit: Int
	private let window: TimeInterval

	/// DI-friendly: you can control the time window and pass `now` in tests.
	init(limit: Int, window: TimeInterval = 5) {
		self.limit = limit
		self.window = window
	}

	@discardableResult
	func add(now: Date) -> Bool {
		
		let cutoff = now.addingTimeInterval(-window)
		timestamps = timestamps.filter { $0 >= cutoff }

		guard timestamps.count < limit else {
			return false
		}

		timestamps.append(now)
		return true
	}
}
