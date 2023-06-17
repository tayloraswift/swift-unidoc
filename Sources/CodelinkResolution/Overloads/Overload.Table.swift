extension Overload
{
    struct Table<Collation> where Collation:PathCollation
    {
        private
        var entries:[String: Overload<Address>.Accumulator]

        init()
        {
            self.entries = [:]
        }
    }
}
extension Overload.Table
{
    subscript(path:some BidirectionalCollection<String>) -> Overload<Address>.Accumulator
    {
        _read
        {
            yield  self.entries[Collation.collate(path), default: .none]
        }
        _modify
        {
            yield &self.entries[Collation.collate(path), default: .none]
        }
    }
}
