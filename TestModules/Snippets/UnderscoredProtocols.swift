public
protocol _BazProtocol
{
    /// comment for bazRequirement
    func bazRequirement()
}
extension _BazProtocol
{
    /// comment for bazExtension
    public
    func bazExtension()
    {
    }
}

public
enum Baz
{
}
extension Baz:_BazProtocol
{
    public
    func bazRequirement()
    {
    }
}
