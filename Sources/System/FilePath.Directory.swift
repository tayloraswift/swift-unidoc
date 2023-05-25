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
extension FilePath.Directory:Sequence
{
    @inlinable public
    func makeIterator() -> FilePath.DirectoryIterator
    {
        .init(self.path)
    }
}
extension FilePath.Directory
{
    /// Recursively visits every node (including nested directories)
    /// within this directory. The yielded file paths begin with the
    /// same components as ``path``.
    @inlinable public
    func walk(with body:(FilePath) throws -> ()) throws
    {
        //  minimize the amount of file descriptors we have open
        var explore:[FilePath] = []
        for next:Result<FilePath.Component, any Error> in self
        {
            let current:FilePath = self.path / (try next.get())
            try body(current)
            explore.append(current)
        }
        for current:FilePath in explore
        {
            try current.directory.walk(with: body)
        }
    }
}
