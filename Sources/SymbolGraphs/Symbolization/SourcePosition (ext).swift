import Symbols

extension SourcePosition
{
    /// Concatenates the bits of the two scalar addresses into a 64-bit integer,
    /// storing the bits of the first operand in the most-significant bits of
    /// the result.
    static
    func .. (high:Int32, self:Self) -> Int64
    {
        .init(high) << 32 | .init(self.rawValue)
    }
}
