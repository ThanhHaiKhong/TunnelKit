
import Foundation
import TunnelKitCore
import TunnelKitOpenVPNCore
import CTunnelKitCore
import CTunnelKitOpenVPNProtocol

extension OpenVPN {

    /**
     Initializes the PRNG. Must be issued before using `OpenVPNSession`.
     
     - Parameter seedLength: The length in bytes of the pseudorandom seed that will feed the PRNG.
     */
    public static func prepareRandomNumberGenerator(seedLength: Int) -> Bool {
        let seed: ZeroingData
        do {
            seed = try SecureRandom.safeData(length: seedLength)
        } catch {
            return false
        }
        return CryptoBox.preparePRNG(withSeed: seed.bytes, length: seed.count)
    }
}
