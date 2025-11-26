import XCTest
@testable import TunnelKitCore
@testable import TunnelKitOpenVPNCore
import CTunnelKitCore
import CTunnelKitOpenVPNProtocol

class CryptoCBCTests: XCTestCase {
    private let cipherKey = ZeroingData(count: 32)

    private let hmacKey = ZeroingData(count: 32)

    private let plainData = Data(hex: "00112233ffddaa")

    private let plainHMACData = Data(hex: "8dd324c81ca32f52e4aa1aa35139deba799a68460e80b0e5ac8bceb043edf6e500112233ffddaa")

    private let encryptedHMACData = Data(hex: "fea3fe87ee68eb21c697e62d3c29f7bea2f5b457d9a7fa66291322fc9c2fe6f700000000000000000000000000000000ebe197e706c3c5dcad026f4e3af1048b")

    private var packetId: [UInt8] = [0x56, 0x34, 0x12, 0x00]

    private var ad: [UInt8] = [0x00, 0x12, 0x34, 0x56]

    private lazy var flags: CryptoFlags = {
        return packetId.withUnsafeBufferPointer { iv in
            ad.withUnsafeBufferPointer { ad in
                CryptoFlags(iv: iv.baseAddress,
                            ivLength: iv.count,
                            ad: ad.baseAddress,
                            adLength: ad.count,
                            forTesting: true)
            }
        }
    }()

    func test_givenDecrypted_whenEncryptWithoutCipher_thenEncodesWithHMAC() {
        let sut = CryptoCBC(cipherName: nil, digestName: "sha256")
        sut.configureEncryption(withCipherKey: nil, hmacKey: hmacKey)

        do {
            let returnedData = try sut.encryptData(plainData, flags: &flags)
            XCTAssertEqual(returnedData, plainHMACData)
        } catch {
            XCTFail("Cannot encrypt: \(error)")
        }
    }

    func test_givenDecrypted_whenEncryptWithCipher_thenEncryptsWithHMAC() {
        let sut = CryptoCBC(cipherName: "aes-128-cbc", digestName: "sha256")
        sut.configureEncryption(withCipherKey: cipherKey, hmacKey: hmacKey)

        do {
            let returnedData = try sut.encryptData(plainData, flags: &flags)
            XCTAssertEqual(returnedData, encryptedHMACData)
        } catch {
            XCTFail("Cannot encrypt: \(error)")
        }
    }

    func test_givenEncodedWithHMAC_thenDecodes() {
        let sut = CryptoCBC(cipherName: nil, digestName: "sha256")
        sut.configureDecryption(withCipherKey: nil, hmacKey: hmacKey)

        do {
            let returnedData = try sut.decryptData(plainHMACData, flags: &flags)
            XCTAssertEqual(returnedData, plainData)
        } catch {
            XCTFail("Cannot decrypt: \(error)")
        }
    }

    func test_givenEncryptedWithHMAC_thenDecrypts() {
        let sut = CryptoCBC(cipherName: "aes-128-cbc", digestName: "sha256")
        sut.configureDecryption(withCipherKey: cipherKey, hmacKey: hmacKey)

        do {
            let returnedData = try sut.decryptData(encryptedHMACData, flags: &flags)
            XCTAssertEqual(returnedData, plainData)
        } catch {
            XCTFail("Cannot decrypt: \(error)")
        }
    }

    func test_givenHMAC_thenVerifies() {
        let sut = CryptoCBC(cipherName: nil, digestName: "sha256")
        sut.configureDecryption(withCipherKey: nil, hmacKey: hmacKey)

        XCTAssertNoThrow(try sut.verifyData(plainHMACData, flags: &flags))
        XCTAssertNoThrow(try sut.verifyData(encryptedHMACData, flags: &flags))
    }
}
