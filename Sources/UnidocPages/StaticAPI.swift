public
protocol StaticAPI:LosslessStringConvertible
{
}
extension StaticAPI where Self:RawRepresentable<String>
{
    @inlinable public
    var description:String { self.rawValue }

    @inlinable public
    init?(_ description:String)
    {
        self.init(rawValue: description)
    }
}
