

import Foundation

extension OpenVPN {

    /// Holds parameters for TLS wrapping.
    public struct TLSWrap: Codable, Equatable {

        /// The wrapping strategy.
        public enum Strategy: String, Codable, Equatable {

            /// Authenticates payload (--tls-auth).
            case auth

            /// Encrypts payload (--tls-crypt).
            case crypt
        }

        /// The wrapping strategy.
        public let strategy: Strategy

        /// The static encryption key.
        public let key: StaticKey

        public init(strategy: Strategy, key: StaticKey) {
            self.strategy = strategy
            self.key = key
        }

        public static func deserialized(_ data: Data) throws -> TLSWrap {
            return try JSONDecoder().decode(TLSWrap.self, from: data)
        }

        public func serialized() -> Data? {
            return try? JSONEncoder().encode(self)
        }
    }
}
