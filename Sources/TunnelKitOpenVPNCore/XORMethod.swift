
import Foundation
import CTunnelKitOpenVPNCore

extension OpenVPN {

    /// The obfuscation method.
    public enum XORMethod: Codable, Equatable {

        /// XORs the bytes in each buffer with the given mask.
        case xormask(mask: Data)

        /// XORs each byte with its position in the packet.
        case xorptrpos

        /// Reverses the order of bytes in each buffer except for the first (abcde becomes aedcb).
        case reverse

        /// Performs several of the above steps (xormask -> xorptrpos -> reverse -> xorptrpos).
        case obfuscate(mask: Data)

        /// This method mapped to native enumeration.
        public var native: XORMethodNative {
            switch self {
            case .xormask:
                return .mask

            case .xorptrpos:
                return .ptrPos

            case .reverse:
                return .reverse

            case .obfuscate:
                return .obfuscate
            }
        }

        /// The optionally associated mask.
        public var mask: Data? {
            switch self {
            case .xormask(let mask):
                return mask

            case .obfuscate(let mask):
                return mask

            default:
                return nil
            }
        }
    }
}
