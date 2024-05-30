@_exported import struct SystemPackage.Errno
@_exported import struct SystemPackage.FilePath

extension FilePath:@unchecked Sendable
{
}
extension FilePath
{
    @available(*, unavailable, message: "Use the `directory` view instead")
    @inlinable public static
    func / (lhs:Self, rhs:Component) -> Self
    {
        lhs.appending(rhs)
    }
    @available(*, unavailable, message: "Use the `directory` view instead")
    @inlinable public static
    func / (lhs:Self, rhs:String) -> Self
    {
        lhs.appending(rhs)
    }
}
extension FilePath
{
    @inlinable
    func open(_ mode:FileDescriptor.AccessMode,
        permissions:
        (
            owner:FilePermissions.Component?,
            group:FilePermissions.Component?,
            other:FilePermissions.Component?
        )?,
        options:FileDescriptor.OpenOptions) throws -> FileDescriptor
    {
        do
        {
            return try .open(self, mode,
                options: options,
                permissions: permissions.map(FilePermissions.init(_:)))
        }
        catch let error as Errno
        {
            throw FileError.opening(self, error)
        }
    }

    @inlinable
    func close(_ file:FileDescriptor) throws
    {
        do
        {
            try file.close()
        }
        catch let error as Errno
        {
            throw FileError.closing(self, error)
        }
    }
}
extension FilePath
{
    @inlinable public
    func open<T>(_ mode:FileDescriptor.AccessMode,
        permissions:
        (
            owner:FilePermissions.Component?,
            group:FilePermissions.Component?,
            other:FilePermissions.Component?
        )? = nil,
        options:FileDescriptor.OpenOptions = [],
        with body:(FileDescriptor) throws -> T) throws -> T
    {
        let file:FileDescriptor = try self.open(mode,
            permissions: permissions,
            options: options)

        let success:T
        do
        {
            success = try body(file)
        }
        catch let error
        {
            //  If the closure throws, we still need to close the file.
            //  But we do not care about any additional errors from that.
            try? file.close()
            throw error
        }

        try self.close(file)
        return success
    }

    @inlinable public
    func open<T>(_ mode:FileDescriptor.AccessMode,
        permissions:
        (
            owner:FilePermissions.Component?,
            group:FilePermissions.Component?,
            other:FilePermissions.Component?
        )? = nil,
        options:FileDescriptor.OpenOptions = [],
        with body:(FileDescriptor) async throws -> T) async throws -> T
    {
        let file:FileDescriptor = try self.open(mode,
            permissions: permissions,
            options: options)

        let success:T
        do
        {
            success = try await body(file)
        }
        catch let error
        {
            try? file.close()
            throw error
        }

        try self.close(file)
        return success
    }
}
extension FilePath
{
    /// Reads a *single* line from this file, without the line terminator.
    ///
    /// This is mostly useful for reading secrets, like keys and tokens.
    @inlinable public
    func readLine() throws -> String
    {
        .init(try self.read().prefix { !$0.isNewline })
    }
}
extension FilePath
{
    @inlinable public
    func read(_:[UInt8].Type = [UInt8].self) throws -> [UInt8]
    {
        try self.open(.readOnly) { try $0.readAll() }
    }
    @inlinable public
    func read(_:String.Type = String.self) throws -> String
    {
        try self.open(.readOnly) { try $0.readAll() }
    }

    // @inlinable public
    // func write(_ buffer:UnsafeBufferPointer<UInt8>) throws
    // {
    //     do
    //     {
    //         let file:FileDescriptor = try .open(self, .writeOnly,
    //             options:        [.create, .truncate],
    //             permissions:    [.ownerReadWrite, .groupRead, .otherRead])
    //         let count:Int = try file.closeAfter
    //         {
    //             try file.write(UnsafeRawBufferPointer.init(buffer))
    //         }
    //         guard count == buffer.count
    //         else
    //         {
    //             throw FileError.incompleteWrite(bytes: count, of: buffer.count, path: self)
    //         }
    //     }
    //     catch let error as FileError
    //     {
    //         throw error
    //     }
    //     catch let error
    //     {
    //         throw FileError.system(error: error, path: self)
    //     }
    // }
    @inlinable public
    func overwrite(with bytes:ArraySlice<UInt8>,
        permissions:
        (
            owner:FilePermissions.Component?,
            group:FilePermissions.Component?,
            other:FilePermissions.Component?
        ) = (.rw, .rw, .r)) throws
    {
        let _:Int = try self.open(.writeOnly,
            permissions: permissions,
            options: [.create, .truncate])
        {
            try $0.writeAll(bytes)
        }
    }
    // @inlinable public
    // func write(_ string:String) throws
    // {
    //     var string:String = string
    //     try string.withUTF8 { try self.write($0) }
    // }
    // // will make the string UTF-8 and contiguous
    // @inlinable public
    // func write(_ string:inout String) throws
    // {
    //     try string.withUTF8 { try self.write($0) }
    // }
}
extension FilePath
{
    @inlinable public
    var directory:Directory { .init(path: self) }
}
