import SymbolGraphCompiler
import SymbolGraphParts
import Symbols
import System

extension SSGC.SymbolDump
{
    init(loading id:__shared SymbolGraphPart.ID,
        from dumps:__shared FilePath.Directory,
        base:borrowing Symbol.FileBase?) throws
    {
        print("Loading symbols: \(id)")

        let path:FilePath = dumps / "\(id)"
        let part:SymbolGraphPart
        do
        {
            part = try .init(json: .init(utf8: try path.read()[...]), id: id)
        }
        catch let error
        {
            throw SSGC.SymbolDumpLoadingError.init(underlying: error, path: path)
        }

        try self.init(from: part, base: base)
    }
}
