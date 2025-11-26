

import Foundation

extension OpenVPN {

    /// Error raised by the configuration parser, with details about the line that triggered it.
    public enum ConfigurationError: Error {

        /// Option syntax is incorrect.
        case malformed(option: String)

        /// A required option is missing.
        case missingConfiguration(option: String)

        /// An option is unsupported.
        case unsupportedConfiguration(option: String)

        /// Passphrase required to decrypt private keys.
        case encryptionPassphrase

        /// Encryption passphrase is incorrect or key is corrupt.
        case unableToDecrypt(error: Error)

        /// The PUSH_REPLY is multipart.
        case continuationPushReply
    }
}
