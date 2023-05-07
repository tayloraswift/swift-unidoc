@_exported import struct SystemPackage.FileDescriptor

extension FileDescriptor
{
    @inlinable public
    func length() throws -> Int
    {
        let count:Int64 = try self.seek(offset: 0, from: .end)
        guard count < .max
        else
        {
            throw FileSeekError.isDirectory
        }
        return .init(count)
    }

    /// Attempts to read the entirety of this file to a string. This involves
    /// a seek operation, followed by a read operation.
    @inlinable public
    func readAll(_:String.Type = String.self) throws -> String
    {
        try .init(unsafeUninitializedCapacity: try self.length())
        {
            let buffer:UnsafeMutableRawBufferPointer = .init($0)
            let read:Int = try self.read(fromAbsoluteOffset: 0, into: buffer)
            if  buffer.count != read
            {
                throw FileReadError.incomplete(read: read, of: buffer.count)
            }
            else
            {
                return read
            }
        }
    }

    /// Attempts to read the entirety of this file to an array of raw bytes.
    /// This involves a seek operation, followed by a read operation.
    @inlinable public
    func readAll(_:[UInt8].Type = [UInt8].self) throws -> [UInt8]
    {
        try .init(unsafeUninitializedCapacity: try self.length())
        {
            let buffer:UnsafeMutableRawBufferPointer = .init($0)
            $1 = try self.read(fromAbsoluteOffset: 0, into: buffer)
            if  buffer.count != $1
            {
                throw FileReadError.incomplete(read: $1, of: buffer.count)
            }
        }
    }
}
