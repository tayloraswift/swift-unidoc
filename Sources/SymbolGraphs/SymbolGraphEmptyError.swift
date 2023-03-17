public
struct SymbolGraphEmptyError:Equatable, Error, Sendable
{
    public
    init()
    {
    }
}
extension SymbolGraphEmptyError:CustomStringConvertible
{
    public
    var description:String
    {
        "Symbolgraph contains no namespaces."
    }
}
