extension Swiftinit
{
    public
    typealias Method = _SwiftinitMethod
}

/// The name of this protocol is ``Swiftinit.Method``.
public
protocol _SwiftinitMethod:LosslessStringConvertible
{
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
