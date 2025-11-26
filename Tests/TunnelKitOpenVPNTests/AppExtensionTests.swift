import XCTest
import NetworkExtension
import TunnelKitCore
import TunnelKitOpenVPNCore
import TunnelKitAppExtension
@testable import TunnelKitOpenVPNAppExtension
import TunnelKitManager
import TunnelKitOpenVPNManager

class AppExtensionTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testConfiguration() {
        let bundleIdentifier = "com.example.Provider"
        let appGroup = "group.com.algoritmico.TunnelKit"

        let hostname = "example.com"
        let port: UInt16 = 1234
        let serverAddress = "\(hostname):\(port)"
        let credentials = OpenVPN.Credentials("foo", "bar")

        var builder = OpenVPN.ConfigurationBuilder()
        builder.ca = OpenVPN.CryptoContainer(pem: "abcdef")
        builder.cipher = .aes128cbc
        builder.digest = .sha256
        builder.remotes = [.init(hostname, .init(.udp, port))]
        builder.mtu = 1230

        var cfg = OpenVPN.ProviderConfiguration("", appGroup: appGroup, configuration: builder.build())
        cfg.username = credentials.username
        let proto: NETunnelProviderProtocol
        do {
            proto = try cfg.asTunnelProtocol(withBundleIdentifier: bundleIdentifier, extra: nil)
        } catch {
            XCTFail(error.localizedDescription)
            return
        }

        XCTAssertEqual(proto.providerBundleIdentifier, bundleIdentifier)
        XCTAssertEqual(proto.serverAddress, serverAddress)
        XCTAssertEqual(proto.username, credentials.username)

        guard let pc = proto.providerConfiguration else {
            return
        }

        let ovpn = pc["configuration"] as? [String: Any]
        XCTAssertEqual(pc["appGroup"] as? String, appGroup)
        XCTAssertEqual(pc["shouldDebug"] as? Bool, cfg.shouldDebug)
        XCTAssertEqual(ovpn?["cipher"] as? String, cfg.configuration.cipher?.rawValue)
        XCTAssertEqual(ovpn?["digest"] as? String, cfg.configuration.digest?.rawValue)
        XCTAssertEqual(ovpn?["ca"] as? String, cfg.configuration.ca?.pem)
        XCTAssertEqual(ovpn?["mtu"] as? Int, cfg.configuration.mtu)
        XCTAssertEqual(ovpn?["renegotiatesAfter"] as? TimeInterval, cfg.configuration.renegotiatesAfter)
    }

    func testDNSResolver() {
        let exp = expectation(description: "DNS")
        DNSResolver.resolve("www.google.com", timeout: 1000, queue: .main) {
            defer {
                exp.fulfill()
            }
            switch $0 {
            case .success:
                break

            case .failure:
                break
            }
        }
        waitForExpectations(timeout: 5.0, handler: nil)
    }

    func testDNSAddressConversion() {
        let testStrings = [
            "0.0.0.0",
            "1.2.3.4",
            "111.222.333.444",
            "1.0.3.255",
            "1.2.255.4",
            "1.2.3.0",
            "255.255.255.255"
        ]
        for expString in testStrings {
            guard let number = DNSResolver.ipv4(fromString: expString) else {
                XCTAssertEqual(expString, "111.222.333.444")
                continue
            }
            let string = DNSResolver.string(fromIPv4: number)
            XCTAssertEqual(string, expString)
        }
    }

    func testEndpointCycling() {
        CoreConfiguration.masksPrivateData = false

        var builder = OpenVPN.ConfigurationBuilder()
        let hostname = "italy.privateinternetaccess.com"
        builder.remotes = [
            .init(hostname, .init(.tcp6, 2222)),
            .init(hostname, .init(.udp, 1111)),
            .init(hostname, .init(.udp4, 3333))
        ]
        let strategy = ConnectionStrategy(configuration: builder.build())

        let expected = [
            "italy.privateinternetaccess.com:TCP6:2222",
            "italy.privateinternetaccess.com:UDP:1111",
            "italy.privateinternetaccess.com:UDP4:3333"
        ]
        var i = 0
        while strategy.hasEndpoints() {
            guard let remote = strategy.currentRemote else {
                break
            }
            XCTAssertEqual(remote.originalEndpoint.description, expected[i])
            i += 1
            guard strategy.tryNextEndpoint() else {
                break
            }
        }
    }

//    func testEndpointCycling4() {
//        CoreConfiguration.masksPrivateData = false
//
//        var builder = OpenVPN.ConfigurationBuilder()
//        builder.hostname = "italy.privateinternetaccess.com"
//        builder.endpointProtocols = [
//            EndpointProtocol(.tcp4, 2222),
//        ]
//        let strategy = ConnectionStrategy(
//            configuration: builder.build(),
//            resolvedRecords: [
//                DNSRecord(address: "111:bbbb:ffff::eeee", isIPv6: true),
//                DNSRecord(address: "11.22.33.44", isIPv6: false),
//            ]
//        )
//
//        let expected = [
//            "11.22.33.44:TCP4:2222"
//        ]
//        var i = 0
//        while strategy.hasEndpoint() {
//            let endpoint = strategy.currentEndpoint()
//            XCTAssertEqual(endpoint.description, expected[i])
//            i += 1
//            strategy.tryNextEndpoint()
//        }
//    }
//
//    func testEndpointCycling6() {
//        CoreConfiguration.masksPrivateData = false
//
//        var builder = OpenVPN.ConfigurationBuilder()
//        builder.hostname = "italy.privateinternetaccess.com"
//        builder.endpointProtocols = [
//            EndpointProtocol(.udp6, 2222),
//        ]
//        let strategy = ConnectionStrategy(
//            configuration: builder.build(),
//            resolvedRecords: [
//                DNSRecord(address: "111:bbbb:ffff::eeee", isIPv6: true),
//                DNSRecord(address: "11.22.33.44", isIPv6: false),
//            ]
//        )
//
//        let expected = [
//            "111:bbbb:ffff::eeee:UDP6:2222"
//        ]
//        var i = 0
//        while strategy.hasEndpoint() {
//            let endpoint = strategy.currentEndpoint()
//            XCTAssertEqual(endpoint.description, expected[i])
//            i += 1
//            strategy.tryNextEndpoint()
//        }
//    }
}
