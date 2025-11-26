import XCTest
@testable import TunnelKitCore
@testable import TunnelKitOpenVPNCore
import CTunnelKitCore
import CTunnelKitOpenVPNProtocol

class EncryptionTests: XCTestCase {
    private var cipherEncKey: ZeroingData!

    private var cipherDecKey: ZeroingData!

    private var hmacEncKey: ZeroingData!

    private var hmacDecKey: ZeroingData!

    override func setUp() {
        cipherEncKey = try! SecureRandom.safeData(length: 32)
        cipherDecKey = try! SecureRandom.safeData(length: 32)
        hmacEncKey = try! SecureRandom.safeData(length: 32)
        hmacDecKey = try! SecureRandom.safeData(length: 32)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCBC() {
        let (client, server) = clientServer("aes-128-cbc", "sha256")

        let plain = Data(hex: "00112233445566778899")
        let encrypted = try! client.encrypter().encryptData(plain, flags: nil)
        let decrypted = try! server.decrypter().decryptData(encrypted, flags: nil)
        XCTAssertEqual(plain, decrypted)
    }

    func testHMAC() {
        let (client, server) = clientServer(nil, "sha256")

        let plain = Data(hex: "00112233445566778899")
        let encrypted = try! client.encrypter().encryptData(plain, flags: nil)
        XCTAssertNoThrow(try server.decrypter().verifyData(encrypted, flags: nil))
    }

    func testGCM() {
        let (client, server) = clientServer("aes-256-gcm", nil)

        let packetId: [UInt8] = [0x56, 0x34, 0x12, 0x00]
        let ad: [UInt8] = [0x00, 0x12, 0x34, 0x56]
        var flags = packetId.withUnsafeBufferPointer { iv in
            ad.withUnsafeBufferPointer { ad in
                CryptoFlags(iv: iv.baseAddress,
                            ivLength: iv.count,
                            ad: ad.baseAddress,
                            adLength: ad.count,
                            forTesting: true)
            }
        }
        let plain = Data(hex: "00112233445566778899")
        let encrypted = try! client.encrypter().encryptData(plain, flags: &flags)
        let decrypted = try! server.decrypter().decryptData(encrypted, flags: &flags)
        XCTAssertEqual(plain, decrypted)
    }

    func testCTR() {
        let (client, server) = clientServer("aes-256-ctr", "sha256")

        let original = Data(hex: "0000000000")
        let ad: [UInt8] = [UInt8](Data(hex: "38afa8f1162096081e000000015ba35373"))
        var flags = ad.withUnsafeBufferPointer {
            CryptoFlags(iv: nil,
                        ivLength: 0,
                        ad: $0.baseAddress,
                        adLength: $0.count,
                        forTesting: true)
        }

//        let expEncrypted = Data(hex: "319bb8e7f8f7930cc4625079dd32a6ef9540c2fc001c53f909f712037ae9818af840b88714")
        let encrypted = try! client.encrypter().encryptData(original, flags: &flags)
//        XCTAssertEqual(encrypted, expEncrypted)

        let decrypted = try! server.decrypter().decryptData(encrypted, flags: &flags)
        XCTAssertEqual(decrypted, original)
    }

    func testCertificateMD5() {
        let path = Bundle.module.path(forResource: "pia-2048", ofType: "pem")!
        let md5 = try! TLSBox.md5(forCertificatePath: path)
        let exp = "e2fccccaba712ccc68449b1c56427ac1"
        XCTAssertEqual(md5, exp)
    }

    func testPrivateKeyDecryption() {
        privateTestPrivateKeyDecryption(pkcs: "1")
        privateTestPrivateKeyDecryption(pkcs: "8")
    }

    private func privateTestPrivateKeyDecryption(pkcs: String) {
        let bundle = Bundle.module
        let encryptedPath = bundle.path(forResource: "tunnelbear", ofType: "enc.\(pkcs).key")!
        let decryptedPath = bundle.path(forResource: "tunnelbear", ofType: "key")!

        XCTAssertThrowsError(try TLSBox.decryptedPrivateKey(fromPath: encryptedPath, passphrase: "wrongone"))
        let decryptedViaPath = try! TLSBox.decryptedPrivateKey(fromPath: encryptedPath, passphrase: "foobar")
        let encryptedPEM = try! String(contentsOfFile: encryptedPath, encoding: .utf8)
        let decryptedViaString = try! TLSBox.decryptedPrivateKey(fromPEM: encryptedPEM, passphrase: "foobar")
        XCTAssertEqual(decryptedViaPath, decryptedViaString)

        let expDecrypted = try! String(contentsOfFile: decryptedPath)
        XCTAssertEqual(decryptedViaPath, expDecrypted)
    }

    func testCertificatePreamble() {
        let url = Bundle.module.url(forResource: "tunnelbear", withExtension: "crt")!
        let cert = OpenVPN.CryptoContainer(pem: try! String(contentsOf: url))
        XCTAssert(cert.pem.hasPrefix("-----BEGIN"))
    }

    private func clientServer(_ c: String?, _ d: String?) -> (CryptoBox, CryptoBox) {
        let client = CryptoBox(cipherAlgorithm: c, digestAlgorithm: d)
        let server = CryptoBox(cipherAlgorithm: c, digestAlgorithm: d)
        XCTAssertNoThrow(try client.configure(withCipherEncKey: cipherEncKey, cipherDecKey: cipherDecKey, hmacEncKey: hmacEncKey, hmacDecKey: hmacDecKey))
        XCTAssertNoThrow(try server.configure(withCipherEncKey: cipherDecKey, cipherDecKey: cipherEncKey, hmacEncKey: hmacDecKey, hmacDecKey: hmacEncKey))
        return (client, server)
    }
}
