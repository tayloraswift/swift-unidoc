import SymbolGraphParts
import SystemIO

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
