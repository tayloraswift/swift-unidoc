import System
import struct SystemPackage.Errno

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
    func read<T>(from fifo:FilePath, with body:(Self) async throws -> T) async throws -> T
    {
        try await fifo.open(.readOnly) { try await body(.init(file: $0)) }
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
        do
        {
            try self.file.writeAll([update.rawValue])
        }
        catch let error as Errno
        {
            throw error == .brokenPipe ? SSGC.StatusStreamError.pipeDisconnected : error
        }
    }
}
