extension MultipartForm
{
    @frozen public
    struct Iterator
    {
        @usableFromInline internal
        var base:IndexingIterator<MultipartView>

        @inlinable internal
        init(base:IndexingIterator<MultipartView>)
        {
            self.base = base
        }
    }
}
extension MultipartForm.Iterator:IteratorProtocol
{
    public mutating
    func next() -> MultipartForm.Item?
    {
        while let part:ArraySlice<UInt8> = self.base.next()
        {
            if  let item:MultipartForm.Item = .init(parsing: part)
            {
                return item
            }
        }

        return nil
    }
}
