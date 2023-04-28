extension CodelinkResolver
{
    struct Table<Collation> where Collation:CodelinkCollation
    {
        private
        var entries:[String: Overloads]

        init()
        {
            self.entries = [:]
        }
    }
}
extension CodelinkResolver.Table
{
    subscript(path:some BidirectionalCollection<String>) -> CodelinkResolver.Overloads?
    {
        _read
        {
            yield  self.entries[Collation.collate(path)]
        }
        _modify
        {
            yield &self.entries[Collation.collate(path)]
        }
    }
}
