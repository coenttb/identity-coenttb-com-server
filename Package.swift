// swift-tools-version:6.0.0

import Foundation
import PackageDescription

extension String {
    static let identityCoenttbCom: Self = "Identity Coenttb Com"
    static let server: Self = "Server"
    static let vaporApp: Self = "Vapor Application"
    static let keyGenerator: Self = "Key Generator"
}

extension Target.Dependency {
    static var identityCoenttbCom: Self { .target(name: .identityCoenttbCom) }
    static var vaporApp: Self { .target(name: .vaporApp) }
}

extension Target.Dependency {
    static var coenttbIdentityProvider: Self { .product(name: "Coenttb Identity Provider", package: "coenttb-identities") }
    static var coenttbVapor: Self { .product(name: "Coenttb Vapor", package: "coenttb-server-vapor") }
    static var coenttbComShared: Self { .product(name: "Coenttb Com Shared", package: "coenttb-com-shared") }
    static var mailgun: Self { .product(name: "Mailgun", package: "coenttb-mailgun") }
    static var postgres: Self { .product(name: "Postgres", package: "coenttb-postgres") }
    static var queuesFluentDriver: Self { .product(name: "QueuesFluentDriver", package: "vapor-queues-fluent-driver") }
    static var dependenciesMacros: Self { .product(name: "DependenciesMacros", package: "swift-dependencies") }
    static var dependenciesTestSupport: Self { .product(name: "DependenciesTestSupport", package: "swift-dependencies") }
    static var vaporTesting: Self { .product(name: "VaporTesting", package: "vapor") }
    static var vaporJWT: Self { .product(name: "JWT", package: "jwt") }
}

let package = Package(
    name: "identity-coenttb-com-server",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(name: .identityCoenttbCom, targets: [.identityCoenttbCom]),
        .library(name: .vaporApp, targets: [.vaporApp]),
        .executable(name: .server, targets: [.server]),
        .executable(name: .keyGenerator, targets: [.keyGenerator])
    ],
    dependencies: [
        .package(url: "https://github.com/coenttb/coenttb-identities.git", branch: "main"),
        .package(url: "https://github.com/coenttb/coenttb-com-shared.git", branch: "main"),
        .package(url: "https://github.com/coenttb/coenttb-server-vapor.git", branch: "main"),
        .package(url: "https://github.com/coenttb/coenttb-postgres.git", branch: "main"),
        .package(url: "https://github.com/coenttb/coenttb-mailgun.git", branch: "main"),
        .package(url: "https://github.com/m-barthelemy/vapor-queues-fluent-driver.git", from: "3.0.0-beta1"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies.git", from: "1.6.0"),
        .package(url: "https://github.com/vapor/jwt.git", from: "5.0.0")
    ],
    targets: [
        .target(
            name: .identityCoenttbCom,
            dependencies: [
                .coenttbComShared,
                .coenttbIdentityProvider,
                .coenttbVapor,
                .mailgun,
                .postgres,
            ]
        ),
        .target(
            name: .vaporApp,
            dependencies: [
                .coenttbVapor,
                .coenttbVapor,
                .coenttbVapor,
                .identityCoenttbCom,
                .queuesFluentDriver
            ]
        ),
        .executableTarget(
            name: .server,
            dependencies: [
                .vaporApp,
                .coenttbVapor,
            ]
        ),
        .executableTarget(
            name: .keyGenerator,
            dependencies: [
                .vaporJWT
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

extension String {
    var tests: Self {
        self + " Tests"
    }
}
