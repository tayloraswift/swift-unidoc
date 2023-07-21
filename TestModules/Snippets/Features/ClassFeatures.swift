/// A base class with two heritable members.
public
class Baseclass
{
    public
    init()
    {
    }

    public
    func method()
    {
    }
}
/// SymbolGraphGen currently does not produce any features for superclass members.
public
class Subclass:Baseclass
{
}
