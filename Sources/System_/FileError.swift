import TraceableErrors

public
enum FileError:Error, Equatable, Sendable
{
    case opening(FilePath, Errno)
    case closing(FilePath, Errno)
}
extension FileError
{
    @inlinable public
    var path:FilePath
    {
        switch self
        {
        case .opening(let path, _):  path
        case .closing(let path, _):  path
        }
    }
}
extension FileError:TraceableError
{
    @inlinable public
    var underlying:any Error
    {
        switch self
        {
        case .opening(_, let error): error
        case .closing(_, let error): error
        }
    }

    public
    var notes:[String]
    {
        switch self
        {
        case .opening(let path, _):  ["While opening file '\(path)'"]
        case .closing(let path, _):  ["While closing file '\(path)'"]
        }
    }
}
