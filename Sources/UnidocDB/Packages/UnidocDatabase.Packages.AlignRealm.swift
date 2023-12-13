import MongoDB
import MongoQL
import Unidoc
import UnidocRecords

extension UnidocDatabase.Packages
{
    enum AlignRealm
    {
        case aligning(Unidoc.Package)
        case aligned(Unidoc.Package, to:Unidoc.Realm?)
    }
}
extension UnidocDatabase.Packages.AlignRealm
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
extension UnidocDatabase.Packages.AlignRealm:Mongo.UpdateQuery
{
    typealias Target = UnidocDatabase.Packages
    typealias Effect = Mongo.One

    var ordered:Bool { false }

    func build(updates:inout Mongo.UpdateEncoder<Mongo.One>)
    {
        updates
        {
            switch self
            {
            case .aligning(let package):
                $0[.q] = .init { $0[Unidex.Package[.id]] = package }
                $0[.u] = .init
                {
                    $0[.set] = .init
                    {
                        $0[Unidex.Package[.realmAligning]] = true
                    }
                }

            case .aligned(let package, let realm):
                $0[.q] = .init { $0[Unidex.Package[.id]] = package }
                $0[.u] = .init
                {
                    $0[.unset] = .init
                    {
                        $0[Unidex.Package[.realmAligning]] = ()
                    }
                    $0[.set] = .init
                    {
                        $0[Unidex.Package[.realm]] = realm as Unidoc.Realm??
                    }
                }
            }
        }
    }
}

