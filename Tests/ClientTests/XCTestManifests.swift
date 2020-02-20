import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ClientTests.allTests),
        testCase(UtilitiesTests.allTests),
    ]
}
#endif
