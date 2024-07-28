import SymbolGraphLinker
import SymbolGraphParts
import SymbolGraphs
import Symbols
import System

extension SSGC
{
    @_spi(testable) public
    struct SymbolCache
    {
        private
        let symbols:SymbolDumps
        private
        var entries:[SymbolGraphPart.ID: SymbolDump]

        @_spi(testable) public
        init(symbols:SymbolDumps, entries:[SymbolGraphPart.ID: SymbolDump] = [:])
        {
            self.symbols = symbols
            self.entries = entries
        }
    }
}
extension SSGC.SymbolCache
{
    @_spi(testable) public mutating
    func load(module:Symbol.Module,
        filter:Set<Symbol.Module> = [],
        base:Symbol.FileBase?,
        as language:Phylum.Language) throws -> SSGC.SymbolCulture?
    {
        guard
        var parts:[SymbolGraphPart.ID] = self.symbols.modules[module]
        else
        {
            return nil
        }

        parts.removeAll
        {
            if  let colony:Symbol.Module = $0.colony, !filter.isEmpty
            {
                !filter.contains(colony)
            }
            else
            {
                false
            }
        }

        if  parts.isEmpty
        {
            return nil
        }

        parts.sort { $0.basename < $1.basename }

        let dumps:[SSGC.SymbolDump] = try parts.map
        {
            (id:SymbolGraphPart.ID) in try
            {
                let symbols:SSGC.SymbolDump = try $0 ?? .init(loading: id,
                    from: self.symbols.location,
                    base: base)

                $0 = symbols
                return symbols
            } (&self.entries[id])
        }

        return .init(language: language, symbols: dumps)
    }
}
