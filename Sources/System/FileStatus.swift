#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#else
#error("unsupported platform")
#endif

import struct SystemPackage.Errno

@frozen public
struct FileStatus
{
    @usableFromInline internal
    let value:stat

    private
    init(value:stat)
    {
        self.value = value
    }
}
extension FileStatus
{
    @inlinable public
    func `is`(_ type:FileType) -> Bool
    {
        self.value.st_mode & S_IFMT == type.mask
    }
}
extension FileStatus
{
    public static
    func status(of path:FilePath) throws -> Self
    {
        try path.withPlatformString
        {
            var value:stat = .init()
            switch stat($0, &value)
            {
            case 0: return .init(value: value)
            case _: throw Errno.init(rawValue: errno)
            }
        }
    }
    public static
    func status(of file:FileDescriptor) throws -> Self
    {
        var value:stat = .init()
        switch fstat(file.rawValue, &value)
        {
        case 0: return .init(value: value)
        case _: throw Errno.init(rawValue: errno)
        }
    }
}
