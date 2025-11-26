import XCTest
@testable import TunnelKitCore
import CTunnelKitCore
import TunnelKitLZO

class CompressionTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSymmetric() {
        XCTAssertTrue(LZOFactory.isSupported())
        let lzo = LZOFactory.create()
        let src = Data([UInt8](repeating: 6, count: 100))
        guard let dst = try? lzo.compressedData(with: src) else {
            XCTFail("Uncompressible data")
            return
        }
        guard let dstDecompressed = try? lzo.decompressedData(with: dst) else {
            XCTFail("Unable to decompress data")
            return
        }
        XCTAssertEqual(src, dstDecompressed)
    }
}
