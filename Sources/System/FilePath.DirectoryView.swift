// this file based on:
// https://github.com/hassila/swift-plugin-manager/blob/main/Sources/PluginManager/FilePathDirectoryView.swift
@_exported import SystemPackage

#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#else
#error("unsupported platform")
#endif

extension FilePath 
{
    @inlinable public 
    var children:DirectoryView 
    {
        .init(self)
    }
    
    @inlinable public 
    func walk(from current:Self = .init(root: nil), _ body:(Self) throws -> ()) rethrows 
    {
        let absolute:Self  = current.isAbsolute ? current : self.appending(current.components)
        // minimize the amount of file descriptors we have open 
        var explore:[Self] = []
        for next:Component in absolute.children 
        {
            let current:Self = current.appending(next)
            try body(current)
            explore.append(current)
        }
        for current:Self in explore 
        {
            try self.walk(from: current, body)
        }
    }
    /// `DirectoryView` provides an iteratable sequence of the contents of a directory referenced by a `FilePath`
    @frozen public
    struct DirectoryView:IteratorProtocol, Sequence  
    {
        #if canImport(Darwin)
        public 
        typealias StreamPointer = UnsafeMutablePointer<DIR>
        #elseif canImport(Glibc)
        public 
        typealias StreamPointer = OpaquePointer
        #endif
        
        public
        var stream:StreamPointer? 
    
        /// - Parameter path: The file system path to provide directory entries for, should reference a directory
        public
        init(_ path:FilePath) 
        {
            self.stream = path.withPlatformString(opendir(_:))
        }
        
        mutating public 
        func next() -> Component? 
        {
            guard let stream:StreamPointer = self.stream
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
                let base:UnsafeMutableRawPointer = .init(entry) + offset
                guard let component:Component = .init(platformString: 
                    base.assumingMemoryBound(to: CInterop.PlatformChar.self))
                else 
                {
                    fatalError("could not read platform string from `dirent.d_name`")
                }
                // ignore `.` and `..`
                guard case .regular = component.kind 
                else 
                {
                    continue 
                }
                return component
            }
            
            closedir(stream)
            self.stream = nil
            return nil
        }
    }
}
