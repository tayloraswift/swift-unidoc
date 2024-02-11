import SymbolGraphLinker
import Symbols
import System

extension SPM
{
    class ResourceFile:SPM.Resource<[UInt8]>
    {
        let path:Symbol.File
        let name:String

        init(location:FilePath, path:Symbol.File)
        {
            self.path = path
            self.name = String.init(self.path.last)

            super.init(location: location)
        }
    }
}
extension SPM.ResourceFile:Identifiable
{
    var id:Symbol.File { self.path }
}
