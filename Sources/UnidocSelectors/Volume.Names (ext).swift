import ModuleGraphs
import Symbols
import UnidocRecords
import URI

extension Volume.Names
{
    @inlinable public static
    func += (uri:inout URI.Path, self:Self)
    {
        uri.append(self.latest ? "\(self.package)" : "\(self.package):\(self.version)")
    }

    public
    func github(blob file:Symbol.File) -> String?
    {
        if  case .github(let path)? = self.origin,
            let refname:String = self.refname
        {
            return "https://github.com\(path)/blob/\(refname)/\(file)"
        }
        else
        {
            return nil
        }
    }
}
