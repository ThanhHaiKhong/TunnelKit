import XCTest
@testable import TunnelKitCore

class DataManipulationTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testUInt() {
        let data = Data([0x22, 0xff, 0xaa, 0xbb, 0x55, 0x66])

        XCTAssertEqual(data.UInt16Value(from: 3), 0x55bb)
        XCTAssertEqual(data.UInt32Value(from: 2), 0x6655bbaa)
        XCTAssertEqual(data.UInt16Value(from: 4), 0x6655)
        XCTAssertEqual(data.UInt32Value(from: 0), 0xbbaaff22)

//        XCTAssertEqual(data.UInt16Value(from: 3), data.UInt16ValueFromPointers(from: 3))
//        XCTAssertEqual(data.UInt32Value(from: 2), data.UInt32ValueFromBuffer(from: 2))
//        XCTAssertEqual(data.UInt16Value(from: 4), data.UInt16ValueFromPointers(from: 4))
//        XCTAssertEqual(data.UInt32Value(from: 0), data.UInt32ValueFromBuffer(from: 0))
    }

    func testZeroingData() {
        let z1 = Z()
        z1.append(Z(Data(hex: "12345678")))
        z1.append(Z(Data(hex: "abcdef")))
        let z2 = z1.withOffset(2, count: 3) // 5678ab
        let z3 = z2.appending(Z(Data(hex: "aaddcc"))) // 5678abaaddcc

        XCTAssertEqual(z1.toData(), Data(hex: "12345678abcdef"))
        XCTAssertEqual(z2.toData(), Data(hex: "5678ab"))
        XCTAssertEqual(z3.toData(), Data(hex: "5678abaaddcc"))
    }

    func testFlatCount() {
        var v: [Data] = []
        v.append(Data(hex: "11223344"))
        v.append(Data(hex: "1122"))
        v.append(Data(hex: "1122334455"))
        v.append(Data(hex: "11223344556677"))
        v.append(Data(hex: "112233"))
        XCTAssertEqual(v.flatCount, 21)
    }

    func testDataUnitDescription() {
        XCTAssertEqual(0.descriptionAsDataUnit, "0B")
        XCTAssertEqual(1.descriptionAsDataUnit, "1B")
        XCTAssertEqual(1024.descriptionAsDataUnit, "1kB")
        XCTAssertEqual(1025.descriptionAsDataUnit, "1kB")
        XCTAssertEqual(548575.descriptionAsDataUnit, "0.52MB")
        XCTAssertEqual(1048575.descriptionAsDataUnit, "1.00MB")
        XCTAssertEqual(1048576.descriptionAsDataUnit, "1.00MB")
        XCTAssertEqual(1048577.descriptionAsDataUnit, "1.00MB")
        XCTAssertEqual(600000000.descriptionAsDataUnit, "0.56GB")
        XCTAssertEqual(1073741823.descriptionAsDataUnit, "1.00GB")
        XCTAssertEqual(1073741824.descriptionAsDataUnit, "1.00GB")
        XCTAssertEqual(1073741825.descriptionAsDataUnit, "1.00GB")
    }
}
