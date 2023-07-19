import ModuleGraphs
import SemanticVersions
import Unidoc
import UnidocRecords

extension Record.Zone
{
    init(_ zone:Unidoc.Zone, package:PackageIdentifier, version:AnyVersion?, refname:String?)
    {
        self.init(id: zone,
            package: package,
            version: version?.description ?? "$anonymous",
            refname: refname,
            latest: true,
            patch: version?.stable?.release)
    }
}
