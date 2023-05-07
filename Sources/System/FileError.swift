import TraceableErrors

public
struct FileError:Error, Sendable
{
    public
    let underlying:any Error
    public
    let path:FilePath

    public
    init(underlying:any Error, path:FilePath)
    {
        self.underlying = underlying
        self.path = path
    }
}
extension FileError:Equatable
{
    public static
    func == (lhs:Self, rhs:Self) -> Bool
    {
        lhs.path == rhs.path && lhs.underlying == rhs.underlying
    }
}
extension FileError:TraceableError
{
    public
    var notes:[String]
    {
        ["In file '\(self.path)'"]
    }
}
