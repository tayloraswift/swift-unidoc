extension SymbolIdentifier
{
    @frozen public 
    enum Language:Unicode.Scalar, Hashable, Sendable 
    {
        case c      = "c"
        case swift  = "s"
    }
}
extension SymbolIdentifier.Language
{
    @inlinable internal
    init?(_ string:Substring)
    {
        if  let rawValue:Unicode.Scalar = string.unicodeScalars.first,
                string.unicodeScalars.count == 1
        {
            self.init(rawValue: rawValue)
        }
        else
        {
            return nil
        }
    }
}
