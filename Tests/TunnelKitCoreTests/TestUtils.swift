import Foundation
@testable import TunnelKitCore

public class TestUtils {
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
