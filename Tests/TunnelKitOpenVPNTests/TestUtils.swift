import Foundation
@testable import TunnelKitCore
import CTunnelKitCore
import CTunnelKitOpenVPNProtocol

public class TestUtils {
    public static func uniqArray(_ v: [Int]) -> [Int] {
        return v.reduce([]) { $0.contains($1) ? $0 : $0 + [$1] }
    }

    public static func generateDataSuite(_ size: Int, _ count: Int) -> [Data] {
        var suite = [Data]()
        for _ in 0..<count {
            suite.append(try! SecureRandom.data(length: size))
        }
        return suite
    }

    private init() {
    }
}

extension Encrypter {
    func encryptData(_ data: Data, flags: UnsafePointer<CryptoFlags>?) throws -> Data {
        let srcLength = data.count
        var dest: [UInt8] = Array(repeating: 0, count: srcLength + 256)
        var destLength = 0
        try data.withUnsafeBytes {
            try encryptBytes($0.bytePointer, length: srcLength, dest: &dest, destLength: &destLength, flags: flags)
        }
        dest.removeSubrange(destLength..<dest.count)
        return Data(dest)
    }
}

extension Decrypter {
    func decryptData(_ data: Data, flags: UnsafePointer<CryptoFlags>?) throws -> Data {
        let srcLength = data.count
        var dest: [UInt8] = Array(repeating: 0, count: srcLength + 256)
        var destLength = 0
        try data.withUnsafeBytes {
            try decryptBytes($0.bytePointer, length: srcLength, dest: &dest, destLength: &destLength, flags: flags)
        }
        dest.removeSubrange(destLength..<dest.count)
        return Data(dest)
    }

    func verifyData(_ data: Data, flags: UnsafePointer<CryptoFlags>?) throws {
        let srcLength = data.count
        try data.withUnsafeBytes {
            try verifyBytes($0.bytePointer, length: srcLength, flags: flags)
        }
    }
}
