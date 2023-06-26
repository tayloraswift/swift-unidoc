extension Repository
{
    @frozen public
    struct Root:Hashable, Equatable, Sendable
    {
        /// The absolute path to the package root, without the `file://` prefix.
        public
        let path:String

        @inlinable public
        init(_ path:String)
        {
            self.path = path
        }
    }
}
extension Repository.Root:ExpressibleByStringLiteral
{
    @inlinable public
    init(stringLiteral:String)
    {
        self.init(stringLiteral)
    }
}
extension Repository.Root:CustomStringConvertible, LosslessStringConvertible
{
    @inlinable public
    var description:String
    {
        self.path
    }
}
