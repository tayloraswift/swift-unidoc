import System

extension SSGC.Toolchain
{
    @frozen public
    struct Paths
    {
        /// A path to the SwiftPM cache directory to use.
        @usableFromInline
        let swiftPM:FilePath.Directory?
        /// A path to a Swift toolchain to use, usually ending in `usr`.
        @usableFromInline
        let usr:FilePath.Directory?

        @inlinable public
        init(swiftPM:FilePath.Directory?, usr:FilePath.Directory?)
        {
            self.swiftPM = swiftPM
            self.usr = usr
        }
    }
}
extension SSGC.Toolchain.Paths
{
    /// Returns the path to the `swift` executable, or just the string `swift`.
    var swiftCommand:String
    {
        guard
        let usr:FilePath.Directory = self.usr
        else
        {
            return "swift"
        }

        let swift:FilePath = usr / "bin" / "swift"
        return swift.string
    }

    var libIndexStore:FilePath
    {
        let name:FilePath.Component
        let usr:FilePath.Directory

        #if os(macOS)

            name = "libIndexStore.dylib"
            usr = self.usr ?? """
            /Applications/Xcode.app/Contents/Developer/Toolchains\
            /XcodeDefault.xctoolchain/usr
            """

        #else

            name = "libIndexStore.so"
            usr = self.usr ?? "/usr"

        #endif

        return usr / "lib" / name
    }
}
