extension FilePath
{
    /// A safe abstraction for iterating directory entries from a directory pointer.
    /// Instances of this type always close their streams on deinit.
    public final
    class DirectoryIterator
    {
        private
        var stream:Stream

        public
        init(_ path:FilePath)
        {
            self.stream = .unopened(path)
        }

        deinit
        {
            self.stream.close()
        }
    }
}
extension FilePath.DirectoryIterator:AsyncIteratorProtocol
{
    public
    func next() async throws -> FilePath.Component?
    {
        try await self.stream.next()
    }
}
