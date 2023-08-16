extension JSON
{
    @frozen @usableFromInline internal
    struct Literal<Value>
    {
        public
        var value:Value

        @inlinable internal
        init(_ value:Value)
        {
            self.value = value
        }
    }
}
extension JSON.Literal<Never?>
{
    /// Encodes `null` to the provided JSON stream.
    @inlinable internal static
    func += (json:inout JSON, self:Self)
    {
        json.utf8 += "null".utf8
    }
}
extension JSON.Literal<Bool>
{
    /// Encodes `true` or `false` to the provided JSON stream.
    @inlinable internal static
    func += (json:inout JSON, self:Self)
    {
        json.utf8 += (self.value ? "true" : "false").utf8
    }
}
extension JSON.Literal where Value:BinaryInteger
{
    /// Encodes this literal’s integer ``value`` to the provided JSON stream. The value’s
    /// ``CustomStringConvertible description`` witness must format the value in base-10.
    @inlinable internal static
    func += (json:inout JSON, self:Self)
    {
        json.utf8 += self.value.description.utf8
    }
}
extension JSON.Literal where Value:StringProtocol
{
    /// Encodes this literal’s string ``value``, with surrounding quotes, to the provided JSON
    /// stream. This function escapes any special characters in the string.
    @inlinable internal static
    func += (json:inout JSON, self:Self)
    {
        json.utf8.append(0x22) // '"'
        for codeunit:UInt8 in self.value.utf8
        {
            if  let code:JSON.EscapeCode = .init(escaping: codeunit)
            {
                json.utf8 += code
            }
            else
            {
                json.utf8.append(codeunit)
            }
        }
        json.utf8.append(0x22) // '"'
    }
}
