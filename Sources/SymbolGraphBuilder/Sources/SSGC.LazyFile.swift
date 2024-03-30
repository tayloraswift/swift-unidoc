import SymbolGraphLinker
import Symbols
import System
import URI

extension SSGC
{
    final
    class LazyFile
    {
        /// The amount of time it took to load this file from disk.
        private(set)
        var loadingTime:Duration
        private
        let location:FilePath
        private
        var content:[UInt8]?

        let path:Symbol.File
        let name:String

        init(location:FilePath, path:Symbol.File, name:String)
        {
            self.loadingTime = .zero
            self.location = location
            self.content = nil
            self.path = path
            self.name = name
        }
    }
}
extension SSGC.LazyFile
{
    convenience
    init(location:FilePath, path:Symbol.File)
    {
        self.init(location: location, path: path, name: String.init(path.last))
    }
    /// Mangles the stem of the filename. This string is case-sensitive, but has all
    /// url-incompatible characters replaced with hyphens (`-`).
    ///
    /// For example, the file `Getting Started.generated.md` would have the mangled stem
    /// `Getting-Started`.
    ///
    /// This identity is only unique within a single module, and only within a single
    /// file type.
    convenience
    init(location:FilePath, root:borrowing SSGC.PackageRoot)
    {
        let path:Symbol.File = root.rebase(location)
        let stem:Substring = path.last.prefix { $0 != "." }
        let name:String = .init(
            decoding: stem.utf8.map { URI.Path.Component.EncodingSet.contains($0) ? 0x2d : $0 },
            as: Unicode.ASCII.self)

        self.init(location: location, path: path, name: name)
    }

    private
    func time<T>(while body:() throws -> T) rethrows -> T
    {
        let start:ContinuousClock.Instant = .now
        defer
        {
            self.loadingTime += start.duration(to: .now)
        }
        print("Loading file \(self.path) ...")
        return try body()
    }
}
extension SSGC.LazyFile:SSGC.ResourceFile
{
    func read(as _:[UInt8].Type = [UInt8].self) throws -> [UInt8]
    {
        if  let content:[UInt8] = self.content
        {
            return content
        }
        else
        {
            let content:[UInt8] = try self.time { try self.location.read() }
            self.content = content
            return content
        }
    }

    func read(as _:String.Type = String.self) throws -> String
    {
        //  We’re not using caching here, because we should only be reading strings once per
        //  file, and we don’t want to keep them in memory.
        try self.time { try self.location.read() }
    }
}
