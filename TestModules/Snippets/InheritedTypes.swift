/// Swift subclasses can inherit and shadow type declarations from
/// their base classes.
///
/// Practically, this means performing name lookup for a nested
/// type ``BaseDerived.Inner`` requires searching the namespace of
/// its base class, ``Base``, but only if ``BaseDerived`` doesn’t
/// have a type of the same name shadowing it.
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
    public
    enum Shadowed
    {
    }
}

public
class BaseDerived:Base
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
    typealias Inherited = BaseDerived.Inner
}
