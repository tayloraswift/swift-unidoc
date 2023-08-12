extension FNV24
{
    /// A same-sized variant of the ``FNV24`` hash that stores the bits normally discarded by
    /// 24-bit hash in the low bits of its raw value.
    ///
    /// For inexplicable reasons, the DocC team decided to truncate the FNV32 hashes to 24 bits
    /// which raises the frequency of hash collisions by a factor of 256. Because a 24-bit hash
    /// occupies the same amount of space as a 32-bit hash, we store the folded hashes as
    /// database keys and perform lookups on ``FNV24`` hashes using query range operators.
    ///
    /// A folded hash isn’t the same thing as the original ``FNV32`` hash, but it is possible
    /// to recover the original hash using ``FNV32.recover(from:)``.
    @frozen public
    struct Extended:Equatable, Hashable, Sendable
    {
        public
        let value:UInt32

        @inlinable internal
        init(value:UInt32)
        {
            self.value = value
        }
    }
}
extension FNV24.Extended:RawRepresentable
{
    @inlinable public
    init(rawValue:Int32)
    {
        self.init(value: .init(bitPattern: rawValue))
    }
    @inlinable public
    var rawValue:Int32 { .init(bitPattern: value) }
}
extension FNV24.Extended
{
    @inlinable public
    init(hashing string:String)
    {
        let full:FNV32 = .init(hashing: string)
        self = full.folded
    }
}
