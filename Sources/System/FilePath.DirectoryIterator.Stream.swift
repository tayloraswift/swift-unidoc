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

extension FilePath.DirectoryIterator
{
    /// An unsafe interface for iterating directory entries from a directory pointer.
    @usableFromInline @frozen internal
    enum Stream
    {
        case unopened(FilePath)
        case opened(FilePath.DirectoryPointer?)
    }
}
extension FilePath.DirectoryIterator.Stream
{
    @SystemActor
    private mutating
    func open() throws -> FilePath.DirectoryPointer?
    {
        switch self
        {
        case .unopened(let path):
            let pointer:FilePath.DirectoryPointer = try path.withPlatformString
            {
                if  let pointer:FilePath.DirectoryPointer = opendir($0)
                {
                    return pointer
                }
                else
                {
                    throw Errno.init(rawValue: errno)
                }
            }
            self = .opened(pointer)
            return pointer

        case .opened(let pointer):
            return pointer
        }
    }
    @SystemActor
    mutating
    func next() throws -> FilePath.Component?
    {
        guard let stream:FilePath.DirectoryPointer = try self.open()
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
        self = .opened(nil)
        return nil
    }
    mutating
    func close()
    {
        guard case .opened(let stream?) = self
        else
        {
            return
        }

        closedir(stream)
        self = .opened(nil)
    }
}
