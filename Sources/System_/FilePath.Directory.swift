#if canImport(Darwin)

import func Darwin.free
import func Darwin.getcwd

#elseif canImport(Glibc)

import func Glibc.free
import func Glibc.getcwd

#else
#error("unsupported platform")
#endif

extension FilePath
{
    /// `Directory` provides an interface for creating a ``DirectoryIterator``.
    /// Directory iteration is lazy; no IO takes place until the caller
    /// requests the first element, and `Directory`  (but not
    /// ``DirectoryIterator``) supports multi-pass iteration.
    @frozen public
    struct Directory:Equatable, Hashable, Sendable
    {
        public
        var path:FilePath

        @inlinable public
        init(path:FilePath)
        {
            self.path = path
        }
    }
}
extension FilePath.Directory
{
    public static
    func current() -> Self?
    {
        guard
        let buffer:UnsafeMutablePointer<CChar> = getcwd(nil, 0)
        else
        {
            return nil
        }
        defer
        {
            free(buffer)
        }

        return .init(path: FilePath.init(platformString: buffer))
    }
}
extension FilePath.Directory
{
    /// A shorthand for creating a directory and (conditionally) cleaning it.
    public
    func create(clean:Bool) throws
    {
        if  clean
        {
            try self.remove()
        }

        try self.create()
    }
    /// Creates the directory, including any implied parent directories if they do not already
    /// exist.
    public
    func create() throws
    {
        try SystemProcess.init(command: "mkdir", "-p", "\(self.path)")()
    }

    public
    func remove() throws
    {
        try SystemProcess.init(command: "rm", "-rf", "\(self.path)")()
    }

    public
    func move(into location:FilePath.Directory) throws
    {
        try SystemProcess.init(command: "mv", "\(self.path)", "\(location.path)/.")()
    }
    public
    func move(replacing destination:FilePath.Directory) throws
    {
        try SystemProcess.init(command: "mv", "-f", "\(self.path)", "\(destination.path)")()
    }

    /// Returns true if a directory exists at ``path``, returns false if
    /// the file does not exist or is not a directory. This method follows symlinks.
    public
    func exists() -> Bool
    {
        if  let status:FileStatus = try? .status(of: self.path)
        {
            status.is(.directory)
        }
        else
        {
            false
        }
    }
}
extension FilePath.Directory
{
    @inlinable public static
    func /= (self:inout Self, next:FilePath.Component)
    {
        self.path.append(next)
    }
    @inlinable public static
    func /= (self:inout Self, next:String)
    {
        self.path.append(next)
    }

    @inlinable public static
    func / (self:consuming Self, next:FilePath.Component) -> Self
    {
        self /= next
        return self
    }
    @inlinable public static
    func / (self:consuming Self, next:String) -> Self
    {
        self /= next
        return self
    }

    @inlinable public static
    func / (self:consuming Self, next:FilePath.Component) -> FilePath
    {
        self /= next
        return self.path
    }
    @inlinable public static
    func / (self:consuming Self, next:String) -> FilePath
    {
        self /= next
        return self.path
    }
}
extension FilePath.Directory:CustomStringConvertible
{
    @inlinable public
    var description:String { "\(self.path)" }
}
extension FilePath.Directory:LosslessStringConvertible
{
    @inlinable public
    init(_ description:String) { self.init(path: .init(description)) }
}
extension FilePath.Directory:ExpressibleByStringInterpolation
{
    @inlinable public
    init(stringLiteral:String) { self.init(stringLiteral) }
}
extension FilePath.Directory:Sequence
{
    @inlinable public
    func makeIterator() -> FilePath.DirectoryIterator
    {
        .init(self.path)
    }
}
extension FilePath.Directory
{
    /// Recursively visits every node (including nested directories) within this directory. The
    /// yielded file paths begin with the same components as ``path``.
    @inlinable public
    func walk(with body:(FilePath) throws -> Bool) throws
    {
        try self.walk { try body($0 / $1) }
    }
    /// Recursively visits every node (including nested directories) within this directory. The
    /// yielded directory paths begin with the same components as ``path``.
    ///
    /// If the closure returns `false`, descendants will not be visited.
    @inlinable public
    func walk(with body:(FilePath.Directory, FilePath.Component) throws -> Bool) throws
    {
        //  minimize the amount of file descriptors we have open
        var explore:[FilePath] = []
        for next:Result<FilePath.Component, any Error> in self
        {
            let next:FilePath.Component = try next.get()
            if  try body(self, next)
            {
                explore.append(self / next)
            }
        }
        for current:FilePath in explore
        {
            try current.directory.walk(with: body)
        }
    }
}
