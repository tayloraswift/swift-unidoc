import MongoDB
import MongoQL
import Unidoc
import UnidocRecords

extension Unidoc.DB.Packages
{
    enum AlignRealm
    {
        case aligning(Unidoc.Package)
        case aligned(Unidoc.Package, to:Unidoc.Realm?)
    }
}
extension Unidoc.DB.Packages.AlignRealm
{
    private
    var package:Unidoc.Package
    {
        switch self
        {
        case .aligning(let package):    package
        case .aligned(let package, _):  package
        }
    }
}
extension Unidoc.DB.Packages.AlignRealm:Mongo.UpdateQuery
{
    typealias Target = Unidoc.DB.Packages
    typealias Effect = Mongo.One

    var ordered:Bool { false }

    func build(updates:inout Mongo.UpdateListEncoder<Mongo.One>)
    {
        updates
        {
            switch self
            {
            case .aligning(let package):
                $0[.q] { $0[Unidoc.PackageMetadata[.id]] = package }
                $0[.u]
                {
                    $0[.set]
                    {
                        $0[Unidoc.PackageMetadata[.realmAligning]] = true
                    }
                }

            case .aligned(let package, let realm):
                $0[.q] { $0[Unidoc.PackageMetadata[.id]] = package }
                $0[.u]
                {
                    $0[.unset]
                    {
                        $0[Unidoc.PackageMetadata[.realmAligning]] = ()
                    }
                    $0[.set]
                    {
                        $0[Unidoc.PackageMetadata[.realm]] = realm as Unidoc.Realm??
                    }
                }
            }
        }
    }
}

