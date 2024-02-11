import SymbolGraphLinker
import Symbols
import System

extension SPM
{
    final
    class ResourceFile:SPM.Resource<[UInt8]>
    {
        let name:String

        override
        init(location:FilePath, path:Symbol.File)
        {
            self.name = String.init(path.last)
            super.init(location: location, path: path)
        }
    }
}
extension SPM.ResourceFile:StaticResourceFile
{
    typealias Content = [UInt8]
}
