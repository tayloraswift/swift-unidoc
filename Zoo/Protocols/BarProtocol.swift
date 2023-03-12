public
protocol BarProtocol:FooProtocol
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
