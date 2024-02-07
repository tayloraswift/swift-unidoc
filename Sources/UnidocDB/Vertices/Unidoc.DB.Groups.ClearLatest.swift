import MongoDB
import MongoQL
import Unidoc
import UnidocRecords

extension Unidoc.DB.Groups
{
    struct ClearLatest
    {
        let package:Unidoc.Package

        init(from package:Unidoc.Package)
        {
            self.package = package
        }
    }
}
extension Unidoc.DB.Groups.ClearLatest:Mongo.UpdateQuery
{
    typealias Target = Unidoc.DB.Groups
    typealias Effect = Mongo.Many

    var ordered:Bool { false }

    func build(updates:inout Mongo.UpdateListEncoder<Mongo.Many>)
    {
        updates
        {
            $0[.multi] = true
            $0[.q]
            {
                let range:ClosedRange<Unidoc.Scalar> = .package(self.package)

                $0[.and]
                {
                    $0 { $0[Unidoc.AnyGroup[.id]] { $0[.gte] = range.lowerBound } }
                    $0 { $0[Unidoc.AnyGroup[.id]] { $0[.lte] = range.upperBound } }
                    $0 { $0[Unidoc.AnyGroup[.realm]] { $0[.exists] = true } }
                }
            }
            $0[.u]
            {
                $0[.unset] { $0[Unidoc.AnyGroup[.realm]] = () }
            }
        }
    }
}
