import XCTest
@testable import TunnelKitCore
import CTunnelKitCore
import CTunnelKitOpenVPNProtocol

class DataPathEncryptionTests: XCTestCase {
    private let cipherKey = try! SecureRandom.safeData(length: 32)

    private let hmacKey = try! SecureRandom.safeData(length: 32)

    private var enc: DataPathEncrypter!

    private var dec: DataPathDecrypter!

    override func setUp() {
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCBC() {
        prepareBox(cipher: "aes-128-cbc", digest: "sha256")
        privateTestDataPathHigh(peerId: nil)
        privateTestDataPathLow(peerId: nil)
    }

    func testFloatingCBC() {
        prepareBox(cipher: "aes-128-cbc", digest: "sha256")
        privateTestDataPathHigh(peerId: 0x64385837)
        privateTestDataPathLow(peerId: 0x64385837)
    }

    func testGCM() {
        prepareBox(cipher: "aes-256-gcm", digest: nil)
        privateTestDataPathHigh(peerId: nil)
        privateTestDataPathLow(peerId: nil)
    }

    func testFloatingGCM() {
        prepareBox(cipher: "aes-256-gcm", digest: nil)
        privateTestDataPathHigh(peerId: 0x64385837)
        privateTestDataPathLow(peerId: 0x64385837)
    }

    func prepareBox(cipher: String, digest: String?) {
        let box = CryptoBox(cipherAlgorithm: cipher, digestAlgorithm: digest)
        try! box.configure(withCipherEncKey: cipherKey, cipherDecKey: cipherKey, hmacEncKey: hmacKey, hmacDecKey: hmacKey)
        enc = box.encrypter().dataPathEncrypter()
        dec = box.decrypter().dataPathDecrypter()
    }

    func privateTestDataPathHigh(peerId: UInt32?) {
        let path = DataPath(
            encrypter: enc,
            decrypter: dec,
            peerId: peerId ?? PacketPeerIdDisabled,
            compressionFraming: .disabled,
            compressionAlgorithm: .disabled,
            maxPackets: 1000,
            usesReplayProtection: false
        )

        if let peerId = peerId {
            enc.setPeerId(peerId)
            dec.setPeerId(peerId)
            XCTAssertEqual(enc.peerId(), peerId & 0xffffff)
            XCTAssertEqual(dec.peerId(), peerId & 0xffffff)
        }

        let expectedPayload = Data(hex: "00112233445566778899")
        let key: UInt8 = 4

        let encrypted = try! path.encryptPackets([expectedPayload], key: key)
        let decrypted = try! path.decryptPackets(encrypted, keepAlive: nil)
        let payload = decrypted.first!

        XCTAssertEqual(payload, expectedPayload)
    }

    func privateTestDataPathLow(peerId: UInt32?) {
        if let peerId = peerId {
            enc.setPeerId(peerId)
            dec.setPeerId(peerId)
            XCTAssertEqual(enc.peerId(), peerId & 0xffffff)
            XCTAssertEqual(dec.peerId(), peerId & 0xffffff)
        }

        let expectedPayload = Data(hex: "00112233445566778899")
        let expectedPacketId: UInt32 = 0x56341200
        let key: UInt8 = 4

        var encryptedPacketBytes: [UInt8] = [UInt8](repeating: 0, count: 1000)
        var encryptedPacketLength: Int = 0
        enc.assembleDataPacket(nil, packetId: expectedPacketId, payload: expectedPayload, into: &encryptedPacketBytes, length: &encryptedPacketLength)
        let encrypted = try! enc.encryptedDataPacket(withKey: key, packetId: expectedPacketId, packetBytes: encryptedPacketBytes, packetLength: encryptedPacketLength)

        var decryptedBytes: [UInt8] = [UInt8](repeating: 0, count: 1000)
        var decryptedLength: Int = 0
        var packetId: UInt32 = 0
        var compressionHeader: UInt8 = 0
        try! dec.decryptDataPacket(encrypted, into: &decryptedBytes, length: &decryptedLength, packetId: &packetId)
        let payload = try! dec.parsePayload(nil, compressionHeader: &compressionHeader, packetBytes: &decryptedBytes, packetLength: decryptedLength)

        XCTAssertEqual(payload, expectedPayload)
        XCTAssertEqual(packetId, expectedPacketId)
    }
}
