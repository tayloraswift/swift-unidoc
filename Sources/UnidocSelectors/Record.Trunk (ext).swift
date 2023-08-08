import ModuleGraphs
import Symbols
import UnidocRecords
import URI

extension Record.Trunk
{
    @inlinable public static
    func += (uri:inout URI.Path, self:Self)
    {
        uri.append(self.latest ? "\(self.package)" : "\(self.package):\(self.version)")
    }

    public
    func url(github file:Symbol.File) -> String?
    {
        if  let refname:String = self.refname,
            let github:String = self.github
        {
            return "https://\(github)/blob/\(refname)/\(file)"
        }
        else
        {
            return nil
        }
    }
}
