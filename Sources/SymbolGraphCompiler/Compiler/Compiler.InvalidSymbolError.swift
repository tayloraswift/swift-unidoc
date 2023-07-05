extension Compiler
{
    public
    enum InvalidSymbolError:Equatable, Error, Sendable
    {
        case file(uri:String)
    }
}
extension Compiler.InvalidSymbolError:CustomStringConvertible
{
    public
    var description:String
    {
        switch self
        {
        case .file(uri: let uri): return "Invalid file uri '\(uri)'."
        }
    }
}
