import XCTest
@testable import TunnelKitCore
import CTunnelKitCore
import CTunnelKitOpenVPNProtocol

// avg on MBA M1 w/ OpenSSL 3.2.0
class EncryptionPerformanceTests: XCTestCase {
    private var cbcEncrypter: Encrypter!

    private var cbcDecrypter: Decrypter!

    private var gcmEncrypter: Encrypter!

    private var gcmDecrypter: Decrypter!

    override func setUp() {
        let cipherKey = try! SecureRandom.safeData(length: 32)
        let hmacKey = try! SecureRandom.safeData(length: 32)

        let cbc = CryptoBox(cipherAlgorithm: "aes-128-cbc", digestAlgorithm: "sha1")
        try! cbc.configure(withCipherEncKey: cipherKey, cipherDecKey: cipherKey, hmacEncKey: hmacKey, hmacDecKey: hmacKey)
        cbcEncrypter = cbc.encrypter()
        cbcDecrypter = cbc.decrypter()

        let gcm = CryptoBox(cipherAlgorithm: "aes-128-gcm", digestAlgorithm: nil)
        try! gcm.configure(withCipherEncKey: cipherKey, cipherDecKey: cipherKey, hmacEncKey: hmacKey, hmacDecKey: hmacKey)
        gcmEncrypter = gcm.encrypter()
        gcmDecrypter = gcm.decrypter()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // 0.461
    func testCBCEncryption() {
        let suite = TestUtils.generateDataSuite(1000, 100000)
        measure {
            for data in suite {
                _ = try! self.cbcEncrypter.encryptData(data, flags: nil)
            }
        }
    }

    // 0.262
    func testGCMEncryption() {
        let suite = TestUtils.generateDataSuite(1000, 100000)
        let ad: [UInt8] = [0x11, 0x22, 0x33, 0x44]
        var flags = ad.withUnsafeBufferPointer {
            CryptoFlags(iv: nil,
                        ivLength: 0,
                        ad: $0.baseAddress,
                        adLength: $0.count,
                        forTesting: true)
        }
        measure {
            for data in suite {
                _ = try! self.gcmEncrypter.encryptData(data, flags: &flags)
            }
        }
    }
}
