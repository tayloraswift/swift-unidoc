@_exported import struct SystemPackage.FilePath

extension FilePath:@unchecked Sendable
{
}
extension FilePath
{
    @inlinable public static
    func / (lhs:Self, rhs:Component) -> Self
    {
        lhs.appending(rhs)
    }
    @inlinable public static
    func / (lhs:Self, rhs:String) -> Self
    {
        lhs.appending(rhs)
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
        do
        {
            let file:FileDescriptor = try .open(self, mode,
                options: options,
                permissions: permissions.map(FilePermissions.init(_:)))
            return try file.closeAfter { try body(file) }
        }
        catch let error
        {
            throw FileError.init(underlying: error, path: self)
        }
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
        do
        {
            let file:FileDescriptor = try .open(self, mode,
                options: options,
                permissions: permissions.map(FilePermissions.init(_:)))

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
            try file.close()
            return success
        }
        catch let error
        {
            throw FileError.init(underlying: error, path: self)
        }
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
    func overwrite(with array:[UInt8],
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
            try $0.writeAll(array)
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
    var directory:Directory
    {
        .init(self)
    }
}
