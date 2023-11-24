extension Symbol
{
    @frozen public
    struct FileBase:Equatable, Hashable, Sendable
    {
        /// The absolute path to a directory, without the `file://` prefix.
        public
        let path:String

        @inlinable public
        init(_ path:String)
        {
            self.path = path
        }
    }
}
extension Symbol.FileBase:ExpressibleByStringLiteral
{
    @inlinable public
    init(stringLiteral:String)
    {
        self.init(stringLiteral)
    }
}
extension Symbol.FileBase:CustomStringConvertible, LosslessStringConvertible
{
    @inlinable public
    var description:String { self.path }
}
extension Symbol.FileBase
{
    /// Rebases the given `uri` against this file base, returning a relative file symbol.
    ///
    /// -   Parameters
    ///     -   uri: A URI beginning with `file://`.
    public
    func rebase(uri:String) throws -> Symbol.File
    {
        guard
        var start:String.Index = uri.index(uri.startIndex,
                offsetBy: 7,
                limitedBy: uri.endIndex),
            uri[..<start] == "file://"
        else
        {
            throw Symbol.FileBaseError.rebasing(uri: uri, against: self)
        }
        for character:Character in self.path
        {
            if  start < uri.endIndex, uri[start] == character
            {
                start = uri.index(after: start)
            }
            else
            {
                throw Symbol.FileBaseError.rebasing(uri: uri, against: self)
            }
        }

        return .init(String.init(uri[start...].drop { $0 == "/" }))
    }
}
