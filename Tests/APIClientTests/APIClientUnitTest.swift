import XCTest
@testable import APIClient

final class RateLimiterTests: XCTestCase {
	func test_allowsWithinLimit() {
		let limiter = RateLimiter(limit: 3, window: 5)
		let t0 = Date(timeIntervalSince1970: 1000)

		XCTAssertTrue(limiter.add(now: t0))
		XCTAssertTrue(limiter.add(now: t0))
		XCTAssertTrue(limiter.add(now: t0))
	}

	func test_blocksWhenOverLimit() {
		let limiter = RateLimiter(limit: 2, window: 5)
		let t0 = Date(timeIntervalSince1970: 2000)

		XCTAssertTrue(limiter.add(now: t0))
		XCTAssertTrue(limiter.add(now: t0))
		XCTAssertFalse(limiter.add(now: t0))
	}

	func test_expirationAfterWindow_allowsAgain() {
		let limiter = RateLimiter(limit: 1, window: 5)
		let t0 = Date(timeIntervalSince1970: 3000)

		XCTAssertTrue(limiter.add(now: t0))
		// Move past the window
		let t1 = Date(timeIntervalSince1970: 3006)
		XCTAssertTrue(limiter.add(now: t1)) // previous hit expired
	}

	func test_partialExpiration_keepsRecent_onlyOldDropped() {
		let limiter = RateLimiter(limit: 2, window: 5)
		let t0 = Date(timeIntervalSince1970: 4000)     // old
		let t1 = Date(timeIntervalSince1970: 4003)     // recent

		XCTAssertTrue(limiter.add(now: t0))
		XCTAssertTrue(limiter.add(now: t1))

		// Advance so t0 expires but t1 remains
		let t2 = Date(timeIntervalSince1970: 4006)
		XCTAssertTrue(limiter.add(now: t2))
	}
	
	func test_reachLimit() {
let limiter = RateLimiter(limit: 2, window: 5)
		let t0 = Date(timeIntervalSince1970: 4000)     // old
		let t1 = Date(timeIntervalSince1970: 4003)     // recent
		let t2 = Date(timeIntervalSince1970: 4005)
		XCTAssertTrue(limiter.add(now: t0))
		XCTAssertTrue(limiter.add(now: t1))
		XCTAssertFalse(limiter.add(now: t2))
	}
	
}
