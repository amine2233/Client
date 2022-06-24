import XCTest

import ClientTests
import ReachabilityTests

var tests = [XCTestCaseEntry]()
tests += ClientTests.__allTests()
tests += ReachabilityTests.__allTests()

XCTMain(tests)
