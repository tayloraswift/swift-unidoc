import Symbols

extension [Symbol.Decl: Symbol.Module]
{
    func sorted(selecting culture:Symbol.Module) -> [Symbol.Decl]
    {
        var symbols:[Symbol.Decl] = self.reduce(into: [])
        {
            if  $1.value == culture
            {
                $0.append($1.key)
            }
        }

        symbols.sort()
        return symbols
    }
}
