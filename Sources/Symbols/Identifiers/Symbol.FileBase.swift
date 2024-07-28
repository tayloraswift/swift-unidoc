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

