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
extension FilePath.DirectoryIterator:IteratorProtocol
{
    public
    func next() -> Result<FilePath.Component, any Error>?
    {
        do
        {
            guard let component:FilePath.Component = try self.stream.next()
            else
            {
                return nil
            }

            return .success(component)
        }
        catch let error
        {
            return .failure(error)
        }
    }
}
