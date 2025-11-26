import XCTest
@testable import TunnelKitCore
@testable import TunnelKitOpenVPNCore
@testable import TunnelKitOpenVPNProtocol
@testable import TunnelKitOpenVPNAppExtension
import CTunnelKitOpenVPNProtocol

// avg on MBA M1 w/ OpenSSL 3.2.0
class DataPathPerformanceTests: XCTestCase {
    private var dataPath: DataPath!

    private var encrypter: DataPathEncrypter!

    private var decrypter: DataPathDecrypter!

    override func setUp() {
        let ck = try! SecureRandom.safeData(length: 32)
        let hk = try! SecureRandom.safeData(length: 32)

        let crypto = try! OpenVPN.EncryptionBridge(.aes128cbc, .sha1, ck, ck, hk, hk)
        encrypter = crypto.encrypter()
        decrypter = crypto.decrypter()

        dataPath = DataPath(
            encrypter: encrypter,
            decrypter: decrypter,
            peerId: PacketPeerIdDisabled,
            compressionFraming: .disabled,
            compressionAlgorithm: .disabled,
            maxPackets: 200,
            usesReplayProtection: false
        )
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

//    // 28ms
//    func testHighLevel() {
//        let packets = TestUtils.generateDataSuite(1200, 1000)
//        var encryptedPackets: [Data]!
//        var decryptedPackets: [Data]!
//        
//        measure {
//            encryptedPackets = try! self.swiftDP.encryptPackets(packets, key: 0)
//            decryptedPackets = try! self.swiftDP.decryptPackets(encryptedPackets, keepAlive: nil)
//        }
//        
//        XCTAssertEqual(decryptedPackets, packets)
//    }

    // 0.007
    func testPointerBased() {
        let packets = TestUtils.generateDataSuite(1200, 1000)
        var encryptedPackets: [Data]!
        var decryptedPackets: [Data]!

        measure {
            encryptedPackets = try! self.dataPath.encryptPackets(packets, key: 0)
            decryptedPackets = try! self.dataPath.decryptPackets(encryptedPackets, keepAlive: nil)
        }

        XCTAssertEqual(decryptedPackets, packets)
    }
}
