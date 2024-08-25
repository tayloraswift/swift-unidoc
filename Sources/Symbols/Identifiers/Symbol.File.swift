extension Symbol
{
    @frozen public
    struct File:Equatable, Hashable, Sendable
    {
        /// The path to the relevant file, relative to some ``FileBase``.
        public
        let path:String

        /// Creates a file identifier from a relative path.
        @inlinable public
        init(_ path:String)
        {
            self.path = path
        }
    }
}
extension Symbol.File
{
    /// Strips the `file://` prefix from the given `uri`, returning a file symbol. Returns nil
    /// if the `uri` does not begin with `file://`.
    @inlinable public
    static func uri(file uri:String) throws -> Self
    {
        guard
        let start:String.Index = uri.index(uri.startIndex,
                offsetBy: 7,
                limitedBy: uri.endIndex),
            uri[..<start] == "file://"
        else
        {
            throw SchemeError.init(uri: uri)
        }

        return .init(String.init(uri[start...]))
    }
}
extension Symbol.File
{
    public mutating
    func rebase(against base:Symbol.FileBase) throws
    {
        self = try self.rebased(against: base)
    }
    /// Rebases the given `uri` against this file base, returning a relative file symbol.
    ///
    /// -   Parameters
    ///     -   uri: A URI beginning with `file://`.
    public __consuming
    func rebased(against base:Symbol.FileBase) throws -> Self
    {
        var start:String.Index = self.path.startIndex
        for character:Character in base.path
        {
            if  start < self.path.endIndex, self.path[start] == character
            {
                start = self.path.index(after: start)
            }
            else
            {
                throw RebaseError.init(base: base, path: self.path)
            }
        }

        return .init(String.init(self.path[start...].drop { $0 == "/" }))
    }
}
extension Symbol.File
{
    /// Returns the last path component of the file ``path``, not including
    /// the path separator (one of `/` or `\`) itself.
    @inlinable public
    var last:Substring
    {
        if  let i:String.Index = self.path.lastIndex(where: { $0 == "/" || $0 == "\\" })
        {
            self.path[self.path.index(after: i)...]
        }
        else
        {
            self.path[...]
        }
    }
    /// Returns the file extension, if any.
    @inlinable public
    var type:Substring?
    {
        self.last.lastIndex(of: ".").map
        {
            self.path[self.path.index(after: $0)...]
        }
    }
}
extension Symbol.File:CustomStringConvertible
{
    @inlinable public
    var description:String { self.path }
}
extension Symbol.File:RawRepresentable
{
    @inlinable public
    var rawValue:String { self.path }

    @inlinable public
    init(rawValue:String)
    {
        self.init(rawValue)
    }
}
extension Symbol.File:Comparable
{
    @inlinable public static
    func < (lhs:Self, rhs:Self) -> Bool
    {
        lhs.path < rhs.path
    }
}
extension Symbol.File:ExpressibleByStringLiteral
{
    @inlinable public
    init(stringLiteral:String)
    {
        self.init(stringLiteral)
    }
}
