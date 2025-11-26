import XCTest
import TunnelKitCore
import TunnelKitOpenVPNCore

class ConfigurationTests: XCTestCase {
    override func setUp() {
        super.setUp()

        CoreConfiguration.masksPrivateData = false
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testRandomizeHostnames() {
        var builder = OpenVPN.ConfigurationBuilder()
        let hostname = "my.host.name"
        let ipv4 = "1.2.3.4"
        builder.remotes = [
            .init(hostname, .init(.udp, 1111)),
            .init(ipv4, .init(.udp4, 3333))
        ]
        builder.randomizeHostnames = true
        let cfg = builder.build()

        cfg.processedRemotes?.forEach {
            let comps = $0.address.components(separatedBy: ".")
            guard let first = comps.first else {
                XCTFail()
                return
            }
            if $0.isHostname {
                XCTAssert($0.address.hasSuffix(hostname))
                XCTAssert(first.count == 12)
                XCTAssert(first.allSatisfy {
                    "0123456789abcdef".contains($0)
                })
            } else {
                XCTAssert($0.address == ipv4)
            }
        }
    }
}
