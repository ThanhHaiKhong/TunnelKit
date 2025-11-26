import XCTest
@testable import TunnelKitCore
@testable import TunnelKitOpenVPNCore
import CTunnelKitCore
import CTunnelKitOpenVPNProtocol

class CryptoAEADTests: XCTestCase {
    private let cipherKey = ZeroingData(count: 32)

    private let hmacKey = ZeroingData(count: 32)

    private let plainData = Data(hex: "00112233ffddaa")

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

    func test_givenData_whenEncrypt_thenDecrypts() {
        let sut = CryptoAEAD(cipherName: "aes-256-gcm")
        sut.configureEncryption(withCipherKey: cipherKey, hmacKey: hmacKey)
        sut.configureDecryption(withCipherKey: cipherKey, hmacKey: hmacKey)
        let encryptedData: Data

        do {
            encryptedData = try sut.encryptData(plainData, flags: &flags)
        } catch {
            XCTFail("Cannot encrypt: \(error)")
            return
        }
        do {
            let returnedData = try sut.decryptData(encryptedData, flags: &flags)
            XCTAssertEqual(returnedData, plainData)
        } catch {
            XCTFail("Cannot decrypt: \(error)")
        }
    }
}
