import SymbolGraphBuilder
import Testing

@Suite struct ToolchainDetectionTests {
    @Test static func SplashParsingLinuxNightly() throws {
        let splash: SSGC.Toolchain.Splash = try .init(
            parsing: """
            Swift version 5.8-dev (LLVM 07d14852a049e40, Swift 613b3223d9ec5f6)
            Target: x86_64-unknown-linux-gnu

            """
        )
        #expect(splash.swift == .init(version: .v(5, 8, 0), nightly: .DEVELOPMENT_SNAPSHOT))
        #expect(splash.triple == .x86_64_unknown_linux_gnu)
    }
    @Test static func SplashParsingLinux() throws {
        let splash: SSGC.Toolchain.Splash = try .init(
            parsing: """
            Swift version 5.10 (swift-5.10-RELEASE)
            Target: x86_64-unknown-linux-gnu

            """
        )
        #expect(splash.swift == .init(version: .v(5, 10, 0), nightly: nil))
        #expect(splash.triple == .x86_64_unknown_linux_gnu)
    }
    @Test static func SplashParsingXcode() throws {
        let splash: SSGC.Toolchain.Splash = try .init(
            parsing: """
            swift-driver version: 1.90.11.1 \
            Apple Swift version 5.10 (swiftlang-5.10.0.13 clang-1500.3.9.4)
            Target: arm64-apple-macosx14.0

            """
        )
        #expect(splash.swift == .init(version: .v(5, 10, 0), nightly: nil))
        #expect(splash.triple == .arm64_apple_macosx14_0)
    }
}
