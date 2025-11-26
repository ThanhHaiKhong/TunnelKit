import XCTest
import TunnelKitCore
import TunnelKitOpenVPNProtocol
import CTunnelKitOpenVPNProtocol

final class XORTests: XCTestCase {
    private let mask = Data(hex: "f76dab30")

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testMask() throws {
        let processor = XORProcessor(method: .xormask(mask: mask))
        processor.assertReversible(try SecureRandom.data(length: 1000))
    }

    func testPtrPos() throws {
        let processor = XORProcessor(method: .xorptrpos)
        processor.assertReversible(try SecureRandom.data(length: 1000))
    }

    func testReverse() throws {
        let processor = XORProcessor(method: .reverse)
        processor.assertReversible(try SecureRandom.data(length: 1000))
    }

    func testObfuscate() throws {
        let processor = XORProcessor(method: .obfuscate(mask: mask))
        processor.assertReversible(try SecureRandom.data(length: 1000))
    }

    func testPacketStream() throws {
        let data = try SecureRandom.data(length: 10000)
        PacketStream.assertReversible(data, method: .none)
        PacketStream.assertReversible(data, method: .mask, mask: mask)
        PacketStream.assertReversible(data, method: .ptrPos)
        PacketStream.assertReversible(data, method: .reverse)
        PacketStream.assertReversible(data, method: .obfuscate, mask: mask)
    }
}

private extension XORProcessor {
    func assertReversible(_ data: Data) {
        let xored = processPacket(data, outbound: true)
        XCTAssertEqual(processPacket(xored, outbound: false), data)
    }
}

private extension PacketStream {
    static func assertReversible(_ data: Data, method: XORMethodNative, mask: Data? = nil) {
        var until = 0
        let outStream = PacketStream.outboundStream(fromPacket: data, xorMethod: method, xorMask: mask)
        let inStream = PacketStream.packets(fromInboundStream: outStream, until: &until, xorMethod: method, xorMask: mask)
        let originalData = Data(inStream.joined())
        XCTAssertEqual(data.toHex(), originalData.toHex())
    }
}
