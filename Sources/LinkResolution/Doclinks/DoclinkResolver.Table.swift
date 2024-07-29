import UCF

extension DoclinkResolver
{
    @frozen public
    struct Table
    {
        @usableFromInline internal
        var entries:[UCF.ResolutionPath: Int32]

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
    subscript(prefix:DoclinkResolver.Prefix, name:String) -> Int32?
    {
        _read
        {
            yield  self.entries[.join(prefix + [name])]
        }
        _modify
        {
            yield &self.entries[.join(prefix + [name])]
        }
    }
}
