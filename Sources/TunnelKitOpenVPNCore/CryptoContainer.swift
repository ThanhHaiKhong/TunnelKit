
import Foundation

// FIXME: remove dependency on TLSBox
import CTunnelKitOpenVPNProtocol

extension OpenVPN {

    /// Represents a cryptographic container in PEM format.
    public struct CryptoContainer: Codable, Equatable {
        private static let begin = "-----BEGIN "

        private static let end = "-----END "

        /// The content in PEM format (ASCII).
        public let pem: String

        var isEncrypted: Bool {
            return pem.contains("ENCRYPTED")
        }

        public init(pem: String) {
            guard let beginRange = pem.range(of: CryptoContainer.begin) else {
                self.pem = ""
                return
            }
            self.pem = String(pem[beginRange.lowerBound...])
        }

        func write(to url: URL) throws {
            try pem.write(to: url, atomically: true, encoding: .ascii)
        }

        // FIXME: remove dependency on TLSBox
        func decrypted(with passphrase: String) throws -> CryptoContainer {
            let decryptedPEM = try TLSBox.decryptedPrivateKey(fromPEM: pem, passphrase: passphrase)
            return CryptoContainer(pem: decryptedPEM)
        }

        // MARK: Codable

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let pem = try container.decode(String.self)
            self.init(pem: pem)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(pem)
        }
    }
}
