extension DOM
{
    @usableFromInline
    typealias Attribute = _DOMAttribute
}

/// The name of this protocol is ``DOM.Attribute``.
@usableFromInline
protocol _DOMAttribute
{
    var name:String { get }
}
extension DOM.Attribute where Self:RawRepresentable<String>
{
    @inlinable internal
    var name:String { self.rawValue }
}
