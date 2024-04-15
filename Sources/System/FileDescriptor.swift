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
        let bytes:Int = try self.length()
        return try .init(unsafeUninitializedCapacity: bytes)
        {
            let buffer:UnsafeMutableRawBufferPointer = .init($0)
            let read:Int = try self.read(fromAbsoluteOffset: 0, into: buffer)
            if  read != bytes
            {
                throw FileReadError.incomplete(read: read, of: bytes)
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
        let bytes:Int = try self.length()
        return try .init(unsafeUninitializedCapacity: bytes)
        {
            let buffer:UnsafeMutableRawBufferPointer = .init($0)
            $1 = try self.read(fromAbsoluteOffset: 0, into: buffer)
            if  $1 != bytes
            {
                throw FileReadError.incomplete(read: $1, of: bytes)
            }
        }
    }
}
extension FileDescriptor
{
    /// Attempts to read UTF-8 text from this file until no more data is available.
    @inlinable public
    func read<Encoding>(_ encoding:Encoding.Type = Unicode.UTF8.self,
        buffering:Int = 4096) throws -> String
        where Encoding:_UnicodeEncoding, Encoding.CodeUnit == UInt8
    {
        .init(decoding: try self.read(buffering: buffering), as: encoding)
    }
    /// Attempts to read raw bytes from this file until no more data is available.
    @inlinable public
    func read(buffering:Int = 4096) throws -> [UInt8]
    {
        let buffer:UnsafeMutableRawBufferPointer = .allocate(byteCount: buffering, alignment: 1)
        defer
        {
            buffer.deallocate()
        }

        var output:[UInt8] = []

        while true
        {
            let bytes:Int = try self.read(into: buffer)

            output += buffer.prefix(bytes)

            if  bytes < buffer.count
            {
                return output
            }
        }
    }

    @inlinable public
    func readByte<Code>(as:Code.Type = Code.self) throws -> Code?
        where Code:RawRepresentable<UInt8>
    {
        try self.readByte().flatMap(Code.init(rawValue:))
    }

    @inlinable public
    func readByte() throws -> UInt8?
    {
        try withUnsafeTemporaryAllocation(byteCount: 1, alignment: 1)
        {
            if  try self.read(into: $0) == 1
            {
                return $0[0]
            }
            else
            {
                return nil
            }
        }
    }
}
