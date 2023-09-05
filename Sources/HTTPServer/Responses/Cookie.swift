@frozen public
struct Cookie:Equatable, Hashable, Sendable
{
    public
    let name:String
    public
    let value:String

    @inlinable public
    init(name:String = "", value:String)
    {
        self.name = name
        self.value = value
    }
}
extension Cookie:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        "\(self.name)=\(self.value)"
    }
}
