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
    ],
    targets: [
        .binaryTarget(
            name: "openssl",
            url: "https://github.com/ThanhHaiKhong/TunnelKit/releases/download/3.2.0/openssl.xcframework.zip",
            checksum: "f497dba40b659e1f762c17198ab1de7f4e59b5b9aa2cd7f32cfe4358c5325c1f"
        ),
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
                "openssl"
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

