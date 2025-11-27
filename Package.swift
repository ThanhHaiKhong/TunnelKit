// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TunnelKit",
    platforms: [
        .iOS(.v15), .macOS(.v12), .tvOS(.v17)
    ],
    products: [
		.singleTargetLibrary("TunnelKit"),
		.singleTargetLibrary("TunnelKitOpenVPN"),
		.singleTargetLibrary("TunnelKitOpenVPNAppExtension"),
		.singleTargetLibrary("TunnelKitLZO")
    ],
    dependencies: [
        .package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver", from: "1.9.0"),
		.package(url: "https://github.com/0xBF90E913/openssl-apple.git", branch: "master")
    ],
    targets: [
//        .binaryTarget(
//            name: "openssl",
//            url: "https://github.com/ThanhHaiKhong/TunnelKit/releases/download/3.5.501/openssl.xcframework.zip",
//            checksum: "61f2f3b4d596cc43a98eee65f70ec840bda070b2710965b5c01c6463b2672357"
//        ),
        .target(
            name: "TunnelKit",
            dependencies: [
                "TunnelKitCore",
                "TunnelKitManager"
            ]
        ),
        .target(
            name: "TunnelKitCore",
            dependencies: [
                "__TunnelKitUtils",
                "CTunnelKitCore",
                "SwiftyBeaver"
            ]
		),
        .target(
            name: "TunnelKitManager",
            dependencies: [
                "SwiftyBeaver"
            ]
		),
        .target(
            name: "TunnelKitAppExtension",
            dependencies: [
                "TunnelKitCore"
            ]
		),
        .target(
            name: "TunnelKitOpenVPN",
            dependencies: [
                "TunnelKitOpenVPNCore",
                "TunnelKitOpenVPNManager"
            ]
		),
        .target(
            name: "TunnelKitOpenVPNCore",
            dependencies: [
                "TunnelKitCore",
                "CTunnelKitOpenVPNCore",
                "CTunnelKitOpenVPNProtocol" // FIXME: remove dependency on TLSBox
            ]
		),
        .target(
            name: "TunnelKitOpenVPNManager",
            dependencies: [
                "TunnelKitManager",
                "TunnelKitOpenVPNCore"
            ]
		),
        .target(
            name: "TunnelKitOpenVPNProtocol",
            dependencies: [
                "TunnelKitOpenVPNCore",
                "CTunnelKitOpenVPNProtocol"
            ]
		),
        .target(
            name: "TunnelKitOpenVPNAppExtension",
            dependencies: [
                "TunnelKitAppExtension",
                "TunnelKitOpenVPNCore",
                "TunnelKitOpenVPNManager",
                "TunnelKitOpenVPNProtocol"
            ]
		),
        .target(
            name: "TunnelKitLZO",
            dependencies: [],
            exclude: [
            ]
		),
        .target(
            name: "CTunnelKitCore",
            dependencies: [
				
			]
		),
        .target(
            name: "CTunnelKitOpenVPNCore",
            dependencies: [
				
			]
		),
        .target(
            name: "CTunnelKitOpenVPNProtocol",
            dependencies: [
                "CTunnelKitCore",
                "CTunnelKitOpenVPNCore",
                "openssl-apple"
            ]
		),
        .target(
            name: "__TunnelKitUtils",
            dependencies: [
				
			]
		)
    ]
)

extension Product {
	static func singleTargetLibrary(_ name: String) -> Product {
		.library(name: name, targets: [name])
	}
}

