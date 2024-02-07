extension HTML.OutputStreamable
{
    /// Calls ``+=(_:_:)`` as an instance method. This method only exists to allow encoding
    /// existentials.
    @inlinable internal
    func encode(to html:inout HTML.ContentEncoder) { html += self }
}
