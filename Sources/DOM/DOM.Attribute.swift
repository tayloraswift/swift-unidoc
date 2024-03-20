extension DOM
{
    @usableFromInline
    protocol Attribute
    {
        var name:String { get }
    }
}
extension DOM.Attribute where Self:RawRepresentable<String>
{
    @inlinable internal
    var name:String { self.rawValue }
}
