import ModuleGraphs
import UnidocRecords
import URI

extension Volume.Names
{
    @inlinable public static
    func += (uri:inout URI.Path, self:Self)
    {
        uri.append(self.latest ? "\(self.package)" : "\(self.package):\(self.version)")
    }
}
