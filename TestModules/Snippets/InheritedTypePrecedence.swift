/// Swift types can inherit typealiases from the protocols they
/// conform to. Subclasses can also inherit types (including
/// typealiases) from the base classes; if they are overloaded,
/// the base class’s declaration wins. 
public
class Base
{
}

extension Base
{
    public
    enum Inner
    {
    }
}

public
protocol Interface
{
}
extension Interface
{
    public
    typealias Inner = UInt8

    public
    typealias Other = Int8
}

public
class BaseDerived:Base, Interface
{
}

extension BaseDerived
{
    public
    struct Shadowed
    {
    }
}
extension BaseDerived
{
    public
    typealias Preferred = BaseDerived.Inner
    public
    typealias Inherited = BaseDerived.Other
}

