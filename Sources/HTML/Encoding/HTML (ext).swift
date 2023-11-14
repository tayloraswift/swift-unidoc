extension HTML
{
    /// Encodes an HTML document with the provided closure, which includes
    /// the prefixed `<!DOCTYPE html>` declaration.
    @inlinable public static
    func document(with encode:(inout ContentEncoder) throws -> ()) rethrows -> Self
    {
        var html:Self = "<!DOCTYPE html>"
        try encode(&html.encoder)
        return html
    }
}
