import XCTest
@testable import TunnelKitCore

class ParsingTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testEndpointV4() {
        let ipAddress = "1.2.3.4"
        let socketType = "TCP"
        let port = 1194
        guard let endpoint = Endpoint(rawValue: "\(ipAddress):\(socketType):\(port)") else {
            XCTFail()
            return
        }
        XCTAssertEqual(endpoint.address, ipAddress)
        XCTAssertEqual(endpoint.proto.socketType.rawValue, socketType)
        XCTAssertEqual(endpoint.proto.port, UInt16(port))
    }

    func testEndpointV6() {
        let ipAddress = "2607:f0d0:1002:51::4"
        let socketType = "TCP"
        let port = 1194
        guard let endpoint = Endpoint(rawValue: "\(ipAddress):\(socketType):\(port)") else {
            XCTFail()
            return
        }
        XCTAssertEqual(endpoint.address, ipAddress)
        XCTAssertEqual(endpoint.proto.socketType.rawValue, socketType)
        XCTAssertEqual(endpoint.proto.port, UInt16(port))
    }
}
