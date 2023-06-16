#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#else
#error("unsupported platform")
#endif

@frozen public
enum FileType:Equatable, Hashable, Sendable
{
    case blockDevice
    case characterDevice
    case directory
    case fifo
    case regular
    case socket
    case symlink
}
extension FileType
{
    @inlinable internal
    var mask:mode_t
    {
        switch self
        {
        case .blockDevice:      return S_IFBLK
        case .characterDevice:  return S_IFCHR
        case .directory:        return S_IFDIR
        case .fifo:             return S_IFIFO
        case .regular:          return S_IFREG
        case .socket:           return S_IFSOCK
        case .symlink:          return S_IFLNK
        }
    }
}
