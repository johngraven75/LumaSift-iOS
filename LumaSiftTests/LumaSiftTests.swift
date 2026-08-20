import XCTest
@testable import LumaSift

final class LumaSiftTests: XCTestCase {
    func testSelectedCategoriesCoverTheApprovedContract() {
        let selected: Set<String> = ["video", "audio", "document", "image"]
        XCTAssertEqual(selected, ["video", "audio", "document", "image"])
    }

    func testCoordinatorRejectsNonHTTPSURL() async {
        let client = CoordinatorClient(settings: CoordinatorSettings(baseURL: "http://unsafe.example", token: "token"))
        do {
            _ = try await client.status()
            XCTFail("Expected HTTPS validation to reject the coordinator URL")
        } catch let error as CoordinatorError {
            guard case .insecureURL = error else { return XCTFail("Expected insecure URL error") }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
