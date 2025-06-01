import Symbols

extension Unidoc.RenderFormat
{
    var availablePlatforms:[Symbol.Triple]
    {
        self.preview ? [
            .aarch64_unknown_linux_gnu,
            .x86_64_unknown_linux_gnu,
            .arm64_apple_macosx14_0,
            .arm64_apple_macosx15_0,
        ] : [
            .aarch64_unknown_linux_gnu,
            .arm64_apple_macosx15_0,
        ]
    }

    var availableVersions:[String]
    {
        ["6.1.2"]
    }
}
