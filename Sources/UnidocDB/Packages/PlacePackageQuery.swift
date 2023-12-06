import MongoQL
import Symbols
import UnidocRecords

struct PlacePackageQuery:Sendable
{
    private
    let package:Symbol.Package

    init(package:Symbol.Package)
    {
        self.package = package
    }
}
//  This used to be a transaction, but we cannot use `$unionWith` in a transaction,
//  and transactions aren’t going to scale for what we need to do afterwards.
//  (e.g. regenerating the all-package search index.)
extension PlacePackageQuery:Mongo.PipelineQuery
{
    typealias CollectionOrigin = UnidocDatabase.PackageAliases
    typealias Collation = SimpleCollation
    typealias Iteration = Mongo.Single<Unidex.PackagePlacement>

    var hint:Mongo.CollectionIndex? { nil }

    func build(pipeline:inout Mongo.PipelineEncoder)
    {
        pipeline[.match] = .init
        {
            $0[Unidex.PackageAlias[.id]] = self.package
        }
        pipeline[.replaceWith] = .init
        {
            $0[Unidex.PackagePlacement[.coordinate]] = Unidex.PackageAlias[.coordinate]
        }
        pipeline[.lookup] = .init
        {
            $0[.from] = UnidocDatabase.Packages.name
            $0[.localField] = Unidex.PackagePlacement[.coordinate]
            $0[.foreignField] = Unidex.Package[.id]
            //  Do not unwind this lookup, because it is possible for alias registration
            //  to succeed while package registration fails, and we need to know that.
            $0[.as] = Unidex.PackagePlacement[.package]
        }
        pipeline[.unionWith] = .init
        {
            $0[.collection] = CollectionOrigin.name
            $0[.pipeline] = .init
            {
                $0[.sort] = .init
                {
                    $0[Unidex.PackageAlias[.coordinate]] = (-)
                }

                $0[.limit] = 1

                $0[.replaceWith] = .init
                {
                    $0[Unidex.PackagePlacement[.coordinate]] = .expr
                    {
                        $0[.add] = (Unidex.PackageAlias[.coordinate], 1)
                    }
                }
            }
        }
        //  Prefer existing registrations, if any.
        pipeline[.sort] = .init
        {
            $0[Unidex.PackagePlacement[.coordinate]] = (+)
        }

        pipeline[.limit] = 1
    }
}
