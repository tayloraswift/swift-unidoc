extension SymbolIdentifier
{
    /// A symbol USR. The only difference between a USR and a symbol identifier
    /// is a symbol USR contains a colon after its language prefix, like
    /// `s:s17FloatingPointSignO`.
    @frozen public
    struct USR
    {
        public
        let symbol:SymbolIdentifier

        @inlinable public
        init(_ symbol:SymbolIdentifier)
        {
            self.symbol = symbol
        }
    }
}
extension SymbolIdentifier.USR:Hashable, Equatable
{
}
extension SymbolIdentifier.USR:RawRepresentable
{
    @inlinable public
    init?(rawValue:String)
    {
        let fragments:[Substring] = rawValue.split(separator: ":",
            omittingEmptySubsequences: true)
        
        if  fragments.count == 2,
            let language:SymbolIdentifier.Language = .init(fragments[0]),
            let symbol:SymbolIdentifier = .init(language, fragments[1])
        {
            self.init(symbol)
        }
        else
        {
            return nil
        }
    }
    @inlinable public
    var rawValue:String
    {
        self.symbol.rawValue.unicodeScalars.first.map
        {
            "\($0):\(self.symbol.rawValue.unicodeScalars.dropFirst())"
        } ?? ""
    }
}
extension SymbolIdentifier.USR:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        self.rawValue
    }
}
