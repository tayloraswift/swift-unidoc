import Symbols

extension SymbolGraphPart
{
    public
    enum IdentificationError:Error, Equatable, Sendable
    {
        case filename(String)
        case culture(ID, expected:Symbol.Module)
    }
}
extension SymbolGraphPart.IdentificationError:CustomStringConvertible
{
    public
    var description:String
    {
        switch self
        {
        case .filename(let filename):
            "Invalid filename: \(filename)."

        case .culture(let id, expected: let culture):
            "Invalid filename: \(id), expected culture '\(culture)'."
        }
    }
}
