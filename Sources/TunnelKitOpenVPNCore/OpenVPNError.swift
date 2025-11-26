
import Foundation
import CTunnelKitOpenVPNCore

/// The possible errors raised/thrown during `OpenVPNSession` operation.
public enum OpenVPNError: Error {

    /// The negotiation timed out.
    case negotiationTimeout

    /// The VPN session id is missing.
    case missingSessionId

    /// The VPN session id doesn't match.
    case sessionMismatch

    /// The connection key is wrong or wasn't expected.
    case badKey

    /// Control channel failure.
    case controlChannel(message: String)

    /// The control packet has an incorrect prefix payload.
    case wrongControlDataPrefix

    /// The provided credentials failed authentication.
    case badCredentials

    /// The reply to PUSH_REQUEST is malformed.
    case malformedPushReply

    /// A write operation failed at the link layer (e.g. network unreachable).
    case failedLinkWrite

    /// The server couldn't ping back before timeout.
    case pingTimeout

    /// The session reached a stale state and can't be recovered.
    case staleSession

    /// Server uses compression.
    case serverCompression

    /// Missing routing information.
    case noRouting

    /// Remote server shut down (--explicit-exit-notify).
    case serverShutdown

    /// NSError from ObjC layer.
    case native(code: OpenVPNErrorCode)
}

extension Error {
    public var asNativeOpenVPNError: OpenVPNError? {
        let nativeError = self as NSError
        guard nativeError.domain == OpenVPNErrorDomain, let code = OpenVPNErrorCode(rawValue: nativeError.code) else {
            return nil
        }
        return .native(code: code)
    }
}
