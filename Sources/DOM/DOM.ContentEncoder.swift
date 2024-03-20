extension DOM
{
    @usableFromInline
    protocol ContentEncoder:StreamingEncoder
    {
        associatedtype AttributeEncoder:StreamingEncoder

        /// Appends a *raw* UTF-8 code unit to the output stream.
        mutating
        func append(escaped codeunit:UInt8)
    }
}
extension DOM.ContentEncoder
{
    /// TODO: Profile to see if this could benefit from a dedicated witness.
    @inlinable mutating
    func append(escaped tag:some RawRepresentable<String>)
    {
        for byte:UInt8 in tag.rawValue.utf8
        {
            self.append(escaped: byte)
        }
    }

    @inlinable mutating
    func emit(opening tag:some RawRepresentable<String>,
        with yield:(inout AttributeEncoder) -> ())
    {
        self.append(escaped: 0x3C) // '<'
        self.append(escaped: tag)
        yield(&self[as: AttributeEncoder.self])
        self.append(escaped: 0x3E) // '>'
    }

    @inlinable mutating
    func emit(closing tag:some RawRepresentable<String>)
    {
        self.append(escaped: 0x3C) // '<'
        self.append(escaped: 0x2F) // '/'
        self.append(escaped: tag)
        self.append(escaped: 0x3E) // '>'
    }
}
