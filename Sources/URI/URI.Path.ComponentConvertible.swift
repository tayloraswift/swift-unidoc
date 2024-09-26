extension URI.Path
{
    public
    protocol ComponentConvertible:LosslessStringConvertible
    {
    }
}
extension URI.Path.ComponentConvertible where Self:RawRepresentable<String>
{
    @inlinable public
    init?(_ description:String) { self.init(rawValue: description) }

    @inlinable public
    var description:String { self.rawValue }
}
