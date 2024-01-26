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

    func build(updates:inout Mongo.UpdateEncoder<Mongo.Many>)
    {
        updates
        {
            $0[.multi] = true
            $0[.q] = .init
            {
                let range:ClosedRange<Unidoc.Scalar> = .package(self.package)

                $0[.and] = .init
                {
                    $0.append
                    {
                        $0[Unidoc.AnyGroup[.id]] = .init { $0[.gte] = range.lowerBound }
                    }
                    $0.append
                    {
                        $0[Unidoc.AnyGroup[.id]] = .init { $0[.lte] = range.upperBound }
                    }
                    $0.append
                    {
                        $0[Unidoc.AnyGroup[.realm]] = .init { $0[.exists] = true }
                    }
                }
            }
            $0[.u] = .init
            {
                $0[.unset] = .init
                {
                    $0[Unidoc.AnyGroup[.realm]] = ()
                }
            }
        }
    }
}
