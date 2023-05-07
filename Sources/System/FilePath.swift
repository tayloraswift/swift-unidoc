@_exported import struct SystemPackage.FilePath

extension FilePath:@unchecked Sendable
{
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
            let permissions:FilePermissions? = permissions.map
            {
                .init(rawValue:
                    ($0.owner?.rawValue ?? 0) << 6 |
                    ($0.group?.rawValue ?? 0) << 3 |
                    ($0.other?.rawValue ?? 0))
            }
            let file:FileDescriptor = try .open(self, mode,
                options: options,
                permissions: permissions)
            return try file.closeAfter { try body(file) }
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
    // @inlinable public
    // func write(_ array:[UInt8]) throws
    // {
    //     try array.withUnsafeBufferPointer { try self.write($0) }
    // }
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
