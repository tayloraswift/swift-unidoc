import Protocols

public
struct Foo
{
}

extension Foo:FooProtocol
{
    public
    func fooRequirement()
    {
    }
}

extension FooProtocol
{
    /// clientExtensionMethod comment
    public
    func clientExtensionMethod()
    {
    }
}

extension FloatingPointSign:FooProtocol
{
    public
    func fooRequirement()
    {
    }
}

extension Bar:BarProtocol
{
}
