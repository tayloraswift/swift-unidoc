extension Swiftinit
{
    public
    protocol Method:LosslessStringConvertible
    {
    }
}
extension Swiftinit.Method where Self:RawRepresentable<String>
{
    @inlinable public
    var description:String { self.rawValue }

    @inlinable public
    init?(_ description:String)
    {
        self.init(rawValue: description)
    }
}
