extension SSGC.Main
{
    enum Option
    {
        /// Where to write the compiled symbol graph.
        case output
        /// Where to write the log of the build process.
        case output_log
        /// The symbolic name of the package to build. This is not the name specified in the
        /// `Package.swift` manifest!
        case package_name
        /// The URL of the git repository to clone.
        case package_repo
        case pretty
        /// The git ref to check out.
        case ref
        /// Whether to remove the Swift build directory after building documentation.
        case remove_build
        /// Whether to remove the cloned git repository after building documentation.
        case remove_clone
        /// Where to look for a SwiftPM package to build, if building locally.
        case search_path
        /// The SDK to pass to the Swift compiler. This should be one of ``SSGC.AppleSDK``.
        case sdk
        /// A path to a FIFO that SSGC will use to communicate its status. If set, SSGC will
        /// block until something opens this FIFO for reading.
        case status
        /// A path to a specific toolchain to use. This should be the path to a binary named
        /// `swift`, usually in a directory named `bin`.
        case swift
        /// A path to the Swift developer runtime libraries.
        ///
        /// On macOS, this is often
        /// `/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib`.
        ///
        /// On Linux, this is often just `/usr/lib`.
        case swift_runtime
        case swiftpm_cache
        /// A path to the workspace directory. SSGC will **assume** this workspace exists.
        case workspace
        /// A path to the workspace directory. SSGC will **create** this workspace unless
        /// ``workspace`` is set.
        case workspace_name
    }
}
extension SSGC.Main.Option
{
    init?(_ string:__shared String)
    {
        switch string
        {
        case "--swiftpm-cache":         self = .swiftpm_cache
        case "--swift-runtime":         self = .swift_runtime
        case "--swift", "-s":           self = .swift
        case "--sdk", "-k":             self = .sdk
        case "--workspace-name", "-w":  self = .workspace_name
        case "--workspace", "-W":       self = .workspace
        case "--status", "-P":          self = .status
        case "--search-path", "-I":     self = .search_path
        case "--package-name", "-n":    self = .package_name
        case "--package-repo", "-r":    self = .package_repo
        case "--ref", "-t":             self = .ref
        case "--output", "-o":          self = .output
        case "--output-log", "-l":      self = .output_log
        case "--remove-build":          self = .remove_build
        case "--remove-clone":          self = .remove_clone
        case "--pretty", "-p":          self = .pretty
        default:                        return nil
        }
    }
}
