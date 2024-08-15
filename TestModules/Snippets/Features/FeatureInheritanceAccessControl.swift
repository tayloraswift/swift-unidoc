protocol P
{
    func f()
}
extension P
{
    public
    func f()
    {
    }
}

/// This type exhibits a known lib/SymbolGraphGen bug, in that it “inherits” the nominally
/// public ``P.f`` method, even though the protocol and all its members are internal.
public
struct S:P
{
}
