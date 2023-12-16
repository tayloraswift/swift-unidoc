import LexicalPaths

extension CodelinkV3.Path.Component
{
    @frozen public
    struct Basename:Equatable, Hashable, Sendable
    {
        public
        let unencased:String

        @inlinable public
        init(unencased:String)
        {
            self.unencased = unencased
        }
    }
}
extension CodelinkV3.Path.Component.Basename:LexicalContinuation
{
    /// Returns ``unencased``, unless it is `init`, `deinit`, or `subscript`,
    /// in which case it will be encased in backticks.
    @inlinable public
    var description:String
    {
        switch self.unencased
        {
        case "init":        "`init`"
        case "deinit":      "`deinit`"
        case "subscript":   "`subscript`"
        case let unencased: unencased
        }
    }
}
extension CodelinkV3.Path.Component.Basename
{
    func lowercased() -> Self
    {
        .init(unencased: self.unencased.lowercased())
    }
}
