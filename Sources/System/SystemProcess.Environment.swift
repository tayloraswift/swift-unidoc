extension SystemProcess
{
    @frozen public
    struct Environment:Sendable
    {
        @usableFromInline
        var encoder:EnvironmentEncoder
        @usableFromInline
        var inherit:Bool

        @inlinable
        init(inherit:Bool)
        {
            self.encoder = .init()
            self.inherit = inherit
        }
    }
}
extension SystemProcess.Environment
{
    @inlinable public static
    var inherit:Self { .init(inherit: true) }

    @inlinable public static
    func inherit(
        adding encode:(inout SystemProcess.EnvironmentEncoder) throws -> Void) rethrows -> Self
    {
        var environment:Self = .inherit
        try encode(&environment.encoder)
        return environment
    }
}
extension SystemProcess.Environment
{
    mutating
    func withUnsafePointers<T>(
        _ yield:(UnsafePointer<UnsafeMutablePointer<CChar>?>?) throws -> T) rethrows -> T
    {
        try self.encoder.buffer.withUnsafeMutableBytes
        {
            guard
            let base:UnsafeMutablePointer<CChar> = $0.bindMemory(to: CChar.self).baseAddress
            else
            {
                return try yield(self.inherit ? environ : nil)
            }

            var inherited:Int = 0
            while case _? = environ[inherited]
            {
                inherited += 1
            }

            return try withUnsafeTemporaryAllocation(of: UnsafeMutablePointer<CChar>?.self,
                capacity: self.encoder.offsets.count + inherited + 1)
            {
                for i:Int in 0 ..< inherited
                {
                    $0.initializeElement(at: i, to: environ[i])
                }
                var i:Int = inherited
                for j:Int in self.encoder.offsets
                {
                    $0.initializeElement(at: i, to: base + self.encoder.offsets[j])
                    i += 1
                }

                $0.initializeElement(at: i, to: nil)

                return try yield($0.baseAddress)
            }
        }
    }
}
