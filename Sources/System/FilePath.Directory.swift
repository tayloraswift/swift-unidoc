extension FilePath
{
    /// `Directory` provides an interface for creating a ``DirectoryIterator``.
    /// Directory iteration is lazy; no IO takes place until the caller
    /// requests the first element, and `Directory`  (but not
    /// ``DirectoryIterator``) supports multi-pass iteration.
    @frozen public
    struct Directory
    {
        public
        let path:FilePath

        @inlinable public
        init(_ path:FilePath)
        {
            self.path = path
        }
    }
}
extension FilePath.Directory:AsyncSequence
{
    public
    typealias Element = FilePath.Component

    @inlinable public
    func makeAsyncIterator() -> FilePath.DirectoryIterator
    {
        .init(self.path)
    }
}
