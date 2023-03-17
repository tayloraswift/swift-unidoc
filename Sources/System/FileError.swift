public 
enum FileError:Error, CustomStringConvertible 
{
    case isDirectory                       (path:FilePath)
    case system               (error:Error, path:FilePath)
    case incompleteRead (bytes:Int, of:Int, path:FilePath)
    case incompleteWrite(bytes:Int, of:Int, path:FilePath)
    
    var path:FilePath 
    {
        switch self 
        {
        case    .isDirectory(                     path: let path),
                .system(error: _,                 path: let path),
                .incompleteRead (bytes: _, of: _, path: let path),
                .incompleteWrite(bytes: _, of: _, path: let path):
            return path
        }
    }
    
    public 
    var description:String 
    {
        switch self 
        {
        case .isDirectory                                          (path: let path):
            return "file '\(path)' is a directory"
        case .system                    (error: let error,          path: let path):
            return "system error '\(error)' while reading file '\(path)'"
        case .incompleteRead (bytes: let read,    of: let expected, path: let path):
            return "could only read \(read) of \(expected) bytes from file '\(path)'"
        case .incompleteWrite(bytes: let written, of: let expected, path: let path):
            return "could only write \(written) of \(expected) bytes to file '\(path)'"
        }
    }
}
