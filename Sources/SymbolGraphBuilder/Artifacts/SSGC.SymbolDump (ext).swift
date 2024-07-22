import SymbolGraphCompiler
import SymbolGraphParts
import Symbols
import System

extension SSGC.SymbolDump
{
    @_spi(testable) public
    init(loading module:__shared Symbol.Module,
        from dumps:borrowing SSGC.SymbolDumps,
        base:borrowing Symbol.FileBase?,
        as language:Phylum.Language) throws
    {
        let parts:[SymbolGraphPart]

        if  var ids:[SymbolGraphPart.ID] = dumps.modules[module]
        {
            ids.sort { $0.basename < $1.basename }

            parts = try ids.map
            {
                let path:FilePath = dumps.location / "\($0)"

                print("Loading symbols: \($0)")

                do
                {
                    return try .init(json: .init(utf8: try path.read()[...]), id: $0)
                }
                catch let error
                {
                    throw SSGC.SymbolDumpLoadingError.init(underlying: error, path: path)
                }
            }
        }
        else
        {
            parts = []
        }

        try self.init(language: language, parts: parts, base: base)
    }
}
