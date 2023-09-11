public
protocol FixedAPI:LosslessStringConvertible
{
}
extension FixedAPI where Self:RawRepresentable<String>
{
    @inlinable public
    var description:String { self.rawValue }

    @inlinable public
    init?(_ description:String)
    {
        self.init(rawValue: description)
    }
}
