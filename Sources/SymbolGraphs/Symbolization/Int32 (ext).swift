extension Int32
{
    /// Concatenates the bits of the two 32-bit integers into a 64-bit integer,
    /// storing the bits of the first operand in the most-significant bits of
    /// the result.
    static
    func .. (high:Self, low:Self) -> Int64
    {
        .init(high) << 32 | .init(low)
    }
}
