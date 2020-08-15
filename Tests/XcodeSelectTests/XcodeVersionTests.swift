import Foundation
import TestFixtures
import Version
import XcodeSelect
import XCTest

final class XcodeVersionTests: XCTestCase {
    func testVersionSorting() throws {
        let xcodeVersions = TestFixtures.allXcodeFixtures.compactMap { try? XcodeVersion(url: $0) }
        let expectedVersions = [
            TestFixtures.xcodeVersion_9_4_1,
            TestFixtures.xcodeVersion_10_0,
            TestFixtures.xcodeVersion_10_3,
            TestFixtures.xcodeVersion_11_2_1,
            TestFixtures.xcodeVersion_11_3_beta1,
            TestFixtures.xcodeVersion_11_3,
            TestFixtures.xcodeVersion_11_3_1,
            TestFixtures.xcodeVersion_11_4_beta1,
            TestFixtures.xcodeVersion_11_4,
            TestFixtures.xcodeVersion_11_4_1,
            TestFixtures.xcodeVersion_11_5,
            TestFixtures.xcodeVersion_11_6,
            TestFixtures.xcodeVersion_11_6_beta1,
            TestFixtures.xcodeVersion_12_beta4,
        ]
        XCTAssertEqual(xcodeVersions, expectedVersions)
    }

    func testVersionParsing() throws {
        for xcodeFixture in TestFixtures.allXcodeFixtures {
            _ = try XcodeVersion(url: xcodeFixture)
        }
    }
}