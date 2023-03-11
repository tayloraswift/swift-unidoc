extension SymbolIdentifier
{
    @frozen public
    struct CompoundUSR
    {
        public
        let base:USR
        public
        let host:USR?

        @inlinable public
        init(_ base:USR, host:USR? = nil)
        {
            self.base = base
            self.host = host
        }
    }
}
extension SymbolIdentifier.CompoundUSR:Hashable, Equatable
{
}
extension SymbolIdentifier.CompoundUSR:RawRepresentable
{
    @inlinable public
    init?(rawValue:String)
    {
        let fragments:[Substring] = rawValue.split(separator: ":",
            omittingEmptySubsequences: true)
        
        switch fragments.count
        {
        case 2:
            if  let language:SymbolIdentifier.Language = .init(fragments[0]),
                let symbol:SymbolIdentifier = .init(language, fragments[1])
            {
                self.init(.init(symbol))
            }
            else
            {
                return nil
            }
        
        case 5:
            if  let language:SymbolIdentifier.Language = .init(fragments[0]),
                let base:SymbolIdentifier = .init(language, fragments[1]),
                "SYNTHESIZED" == fragments[2],
                let language:SymbolIdentifier.Language = .init(fragments[3]),
                let host:SymbolIdentifier = .init(language, fragments[4])
            {
                self.init(.init(base), host: .init(host))
            }
            else
            {
                return nil
            }
        
        case _:
            return nil
        }
    }
    @inlinable public
    var rawValue:String
    {
        self.host.map { "\(self.base)::SYNTHESIZED::\($0)" } ?? self.base.description
    }
}
extension SymbolIdentifier.CompoundUSR:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        self.rawValue
    }
}
