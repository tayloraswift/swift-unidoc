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
extension FilePath.Directory
{
    /// A shorthand for creating a directory and (conditionally) cleaning it.
    public
    func create(clean:Bool) throws
    {
        if  clean
        {
            try self.remove()
        }

        try self.create()
    }
    /// Creates the directory, including any implied parent directories if they do not already
    /// exist.
    public
    func create() throws
    {
        try SystemProcess.init(command: "mkdir", "-p", "\(self.path)")()
    }

    public
    func remove() throws
    {
        try SystemProcess.init(command: "rm", "-rf", "\(self.path)")()
    }

    /// Returns true if a directory exists at ``path``, returns false if
    /// the file does not exist or is not a directory.
    public
    func exists() -> Bool
    {
        if  let status:FileStatus = try? .status(of: self.path)
        {
            status.is(.directory)
        }
        else
        {
            false
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
        try self.walk { try body($0 / $1) }
    }
    @inlinable public
    func walk(with body:(FilePath, FilePath.Component) throws -> ()) throws
    {
        //  minimize the amount of file descriptors we have open
        var explore:[FilePath] = []
        for next:Result<FilePath.Component, any Error> in self
        {
            let next:FilePath.Component = try next.get()
            try body(self.path, next)
            explore.append(self.path / next)
        }
        for current:FilePath in explore
        {
            try current.directory.walk(with: body)
        }
    }
}
