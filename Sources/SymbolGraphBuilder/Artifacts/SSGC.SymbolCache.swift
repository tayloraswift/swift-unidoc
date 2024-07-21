import SymbolGraphLinker
import SymbolGraphParts
import SymbolGraphs
import Symbols
import System

extension SSGC
{
    struct SymbolCache
    {
        private
        let symbols:SymbolDumps
        private
        var entries:[Symbol.Module: SymbolDump]

        init(symbols:SymbolDumps, entries:[Symbol.Module: SymbolDump] = [:])
        {
            self.symbols = symbols
            self.entries = entries
        }
    }
}
extension SSGC.SymbolCache
{
    mutating
    func load(module:Symbol.Module,
        base:Symbol.FileBase?,
        as language:Phylum.Language) throws -> SSGC.SymbolDump?
    {
        try
        {
            $0 = try $0 ?? .init(loading: module,
                from: self.symbols,
                base: base,
                as: language)

            return $0
        } (&self.entries[module])
    }
}
