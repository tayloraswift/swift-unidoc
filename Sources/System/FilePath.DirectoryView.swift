// this file based on:
// https://github.com/hassila/swift-plugin-manager/blob/main/Sources/PluginManager/FilePathDirectoryView.swift
import SystemPackage

#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#else
#error("unsupported platform")
#endif

extension FilePath.DirectoryView
{
    #if canImport(Darwin)
    public
    typealias StreamPointer = UnsafeMutablePointer<DIR>
    #elseif canImport(Glibc)
    public
    typealias StreamPointer = OpaquePointer
    #endif
}
extension FilePath
{
    /// `DirectoryView` provides an iteratable sequence of the contents of a directory
    /// identified by a ``FilePath``
    public final
    class DirectoryView
    {
        @usableFromInline internal
        var stream:Result<StreamPointer?, Errno>

        /// - Parameter path: The file system path to provide directory entries for.
        @inlinable internal
        init(_ path:FilePath)
        {
            self.stream = path.withPlatformString
            {
                if  let pointer:StreamPointer = opendir($0)
                {
                    return .success(pointer)
                }
                else
                {
                    return .failure(.init(rawValue: errno))
                }
            }
        }

        deinit
        {
            if  case .success(let stream?) = self.stream
            {
                closedir(stream)
            }
        }
    }
}
extension FilePath.DirectoryView:AsyncSequence
{
    @inlinable public
    func makeAsyncIterator() -> FilePath.DirectoryView
    {
        self
    }
}
extension FilePath.DirectoryView:AsyncIteratorProtocol
{
    public
    typealias Element = FilePath.Component

    public
    func next() async throws -> FilePath.Component?
    {
        guard let stream:StreamPointer = try self.stream.get()
        else
        {
            return nil
        }

        guard let offset:Int = MemoryLayout<dirent>.offset(of: \.d_name)
        else
        {
            fatalError("invalid `dirent` layout")
        }
        while let entry:UnsafeMutablePointer<dirent> = readdir(stream)
        {
            // `entry` is likely statically-allocated, and has variable-length layout.
            //  attemping to unbind or rebind memory would be meaningless, as we must
            //  rely on the kernel to protect us from buffer overreads.
            let field:UnsafeMutableRawPointer = .init(entry) + offset
            let name:UnsafeMutablePointer<CInterop.PlatformChar> = field.assumingMemoryBound(
                to: CInterop.PlatformChar.self)

            guard let component:FilePath.Component = .init(platformString: name)
            else
            {
                fatalError("could not read platform string from `dirent.d_name`")
            }
            // ignore `.` and `..`
            if  case .regular = component.kind
            {
                return component
            }
            else
            {
                continue
            }
        }

        closedir(stream)
        self.stream = .success(nil)
        return nil
    }
}
