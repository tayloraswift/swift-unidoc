import System_

extension SSGC.PackageBuild
{
    @frozen public
    struct Flags
    {
        public
        var swift:[String]
        public
        var cxx:[String]
        public
        var c:[String]

        @inlinable public
        init(swift:[String] = [], cxx:[String] = [], c:[String] = [])
        {
            self.swift = swift
            self.cxx = cxx
            self.c = c
        }
    }
}
extension SSGC.PackageBuild.Flags
{
    /// This is pretty useless right now, because `swift build -emit-symbol-graph` incorrectly
    /// duplicates `@_exported` symbols. But Apple might fix this in the future, which would be
    /// a much better way to generate symbol graphs than the current method of using
    /// `swift symbolgraph-extract`.
    consuming
    func dumping(symbols options:SSGC.Toolchain.SymbolDumpOptions,
        to output:FilePath.Directory) -> Self
    {
        self.dump(symbols: options, to: output)
        return self
    }

    mutating
    func dump(symbols options:SSGC.Toolchain.SymbolDumpOptions, to output:FilePath.Directory)
    {
        self.swift.append("-emit-symbol-graph")

        self.swift.append("-emit-symbol-graph-dir")
        self.swift.append("\(output.path)")

        self.swift.append("-symbol-graph-minimum-access-level")
        self.swift.append("\(options.minimumACL)")

        if  options.emitExtensionBlockSymbols
        {
            self.swift.append("-emit-extension-block-symbols")
        }
        if  options.includeInterfaceSymbols
        {
            self.swift.append("-include-spi-symbols")
        }
        if  options.skipInheritedDocs
        {
            self.swift.append("-skip-inherited-docs")
        }
    }
}
