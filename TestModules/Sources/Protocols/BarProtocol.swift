public
protocol BarProtocol:FooProtocol, Identifiable
{
}
extension BarProtocol
{
    /// Comment for fooRequirement implementation from BarProtocol
    public
    func fooRequirement()
    {
    }
    /// Comment for barExtensionMethod
    public
    func barExtensionMethod()
    {
    }
}
extension Identifiable where Self:BarProtocol
{
    /// Comment for id
    public var id:Int { 0 }

}
