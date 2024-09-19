import SymbolGraphParts
import System_

extension SSGC
{
    struct SymbolFiles
    {
        let location:FilePath.Directory
        var parts:[SymbolGraphPart.ID]

        init(location:FilePath.Directory, parts:[SymbolGraphPart.ID] = [])
        {
            self.location = location
            self.parts = parts
        }
    }
}
