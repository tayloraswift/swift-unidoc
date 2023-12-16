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
        case .blockDevice:      S_IFBLK
        case .characterDevice:  S_IFCHR
        case .directory:        S_IFDIR
        case .fifo:             S_IFIFO
        case .regular:          S_IFREG
        case .socket:           S_IFSOCK
        case .symlink:          S_IFLNK
        }
    }
}
