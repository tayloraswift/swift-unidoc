@_exported import SystemPackage

extension FilePath 
{
    @inlinable public 
    func read(_:[UInt8].Type = [UInt8].self) throws -> [UInt8]
    {
        let (count, array):(Int, [UInt8]) = try self.read
        {
            (file:FileDescriptor, count:Int) in 
            (
                count: count, 
                array: try .init(unsafeUninitializedCapacity: count)
                {
                    $1 = try file.read(fromAbsoluteOffset: 0, into: UnsafeMutableRawBufferPointer.init($0))
                }
            )
        }
        if count != array.count 
        {
            throw FileError.incompleteRead(bytes: array.count, of: count, path: self)
        }
        else 
        {
            return array
        }
    }
    @inlinable public 
    func read(_:String.Type = String.self) throws -> String
    {
        let (count, string):(Int, String) = try self.read
        {
            (file:FileDescriptor, count:Int) in 
            (
                count: count, 
                string: try .init(unsafeUninitializedCapacity: count)
                {
                    try file.read(fromAbsoluteOffset: 0, into: UnsafeMutableRawBufferPointer.init($0))
                }
            )
        }
        if count != string.utf8.count 
        {
            throw FileError.incompleteRead(bytes: string.utf8.count, of: count, path: self)
        }
        else 
        {
            return string
        }
    }
    @inlinable public 
    func read<T>(_ initializer:(FileDescriptor, Int) throws -> T) throws -> T
    {
        do 
        {
            let file:FileDescriptor = try .open(self, .readOnly)
            return try file.closeAfter 
            {
                let count:Int64 = try file.seek(offset: 0, from: .end)
                guard count < .max
                else 
                {
                    throw FileError.isDirectory(path: self)
                }
                return try initializer(file, Int.init(count))
            }
        }
        catch let error as FileError 
        {
            throw error 
        }
        catch let error 
        {
            throw FileError.system(error: error, path: self)
        }
    }
    
    @inlinable public 
    func write(_ buffer:UnsafeBufferPointer<UInt8>) throws 
    {
        do 
        {
            let file:FileDescriptor = try .open(self, .writeOnly, 
                options:        [.create, .truncate], 
                permissions:    [.ownerReadWrite, .groupRead, .otherRead])
            let count:Int = try file.closeAfter 
            {
                try file.write(UnsafeRawBufferPointer.init(buffer))
            }
            guard count == buffer.count
            else
            {
                throw FileError.incompleteWrite(bytes: count, of: buffer.count, path: self)
            }
        }
        catch let error as FileError 
        {
            throw error 
        }
        catch let error 
        {
            throw FileError.system(error: error, path: self)
        }
    }
    @inlinable public 
    func write(_ array:[UInt8]) throws
    {
        try array.withUnsafeBufferPointer { try self.write($0) }
    }
    @inlinable public 
    func write(_ string:String) throws
    {
        var string:String = string 
        try string.withUTF8 { try self.write($0) }
    }
    // will make the string UTF-8 and contiguous 
    @inlinable public 
    func write(_ string:inout String) throws
    {
        try string.withUTF8 { try self.write($0) }
    }
}
