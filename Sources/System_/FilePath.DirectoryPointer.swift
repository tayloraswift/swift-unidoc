#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#else
#error("unsupported platform")
#endif

extension FilePath
{
    #if canImport(Darwin)
    @usableFromInline internal
    typealias DirectoryPointer = UnsafeMutablePointer<DIR>
    #elseif canImport(Glibc)
    @usableFromInline internal
    typealias DirectoryPointer = OpaquePointer
    #endif
}
