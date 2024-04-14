import System

extension SSGC
{
    @frozen public
    struct StatusStream
    {
        @usableFromInline
        let file:FileDescriptor

        @inlinable
        init(file:FileDescriptor)
        {
            self.file = file
        }
    }
}
extension SSGC.StatusStream
{
    @inlinable public static
    func read<T>(from fifo:FilePath, with body:(Self) throws -> T) throws -> T
    {
        try fifo.open(.readOnly) { try body(.init(file: $0)) }
    }

    @inlinable public
    func next() throws -> SSGC.StatusUpdate?
    {
        try self.file.readByte(as: SSGC.StatusUpdate.self)
    }
}
extension SSGC.StatusStream
{
    static
    func write(to fifo:FilePath, with body:(Self) throws -> SSGC.StatusUpdate) throws
    {
        try fifo.open(.writeOnly, permissions: (.rw, .r, .r))
        {
            let status:Self = .init(file: $0)
            let last:SSGC.StatusUpdate = try body(status)
            try status.send(last)
        }
    }

    func send(_ update:SSGC.StatusUpdate) throws
    {
        try self.file.writeAll([update.rawValue])
    }
}
