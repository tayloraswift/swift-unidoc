import LexicalPaths

extension Codelink.Path.Component
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
extension Codelink.Path.Component.Basename:LexicalContinuation
{
    /// Returns ``unencased``, unless it is `init`, `deinit`, or `subscript`,
    /// in which case it will be encased in backticks.
    @inlinable public
    var description:String
    {
        switch self.unencased
        {
        case "init":        return "`init`"
        case "deinit":      return "`deinit`"
        case "subscript":   return "`subscript`"
        case let unencased: return unencased
        }
    }
}
extension Codelink.Path.Component.Basename
{
    func lowercased() -> Self
    {
        .init(unencased: self.unencased.lowercased())
    }
}
