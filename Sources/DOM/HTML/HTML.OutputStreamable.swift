extension HTML
{
    public
    typealias OutputStreamable = _HTMLOutputStreamable
}

@available(*, deprecated, renamed: "HTML.OutputStreamable")
public
typealias HyperTextOutputStreamable = HTML.OutputStreamable

/// The name of this protocol is ``HTML.OutputStreamable``.
public
protocol _HTMLOutputStreamable
{
    /// Encodes attributes to its parent element when encoded with **single-element subscript
    /// assignment**. Ignored when streamed generally to an ``HTML.ContentEncoder``.
    ///
    /// This operator is declared as a requirement in order to prevent unexpected behavior when
    /// encoding through generics. Because the attributes are sometimes ignored depending on
    /// how the value is encoded, we **strongly recommend** against relying on this operator as
    /// a shortcut for encoding attributes and to witness it instead by declaring conformances
    /// to well-documented protocols such as ``HTML.OutputStreamableAnchor``.
    static
    func += (html:inout HTML.AttributeEncoder, self:Self)

    /// Encodes an instance of this type to the provided HTML stream.
    static
    func += (html:inout HTML.ContentEncoder, self:Self)
}
extension HTML.OutputStreamable
{
    /// Does nothing.
    @inlinable public static
    func += (html:inout HTML.AttributeEncoder, self:Self)
    {
    }
}
extension HTML.OutputStreamable where Self:StringProtocol
{
    @inlinable public static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        html += self.utf8
    }
}
