extension DoclinkResolver
{
    @frozen public
    struct Table
    {
        @usableFromInline internal
        var entries:[DoclinkResolutionPath: Int32]

        @inlinable public
        init()
        {
            self.entries = [:]
        }
    }
}
extension DoclinkResolver.Table
{
    @inlinable public
    subscript(scope:DoclinkResolver.Scope, name:String) -> Int32?
    {
        _read
        {
            yield  self.entries[.join(scope + [name])]
        }
        _modify
        {
            yield &self.entries[.join(scope + [name])]
        }
    }
}
