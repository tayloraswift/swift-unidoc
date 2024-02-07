import MongoQL
import SemanticVersions
import SymbolGraphs
import Symbols
import Unidoc
import UnidocRecords

extension Unidoc
{
    struct PinDependenciesQuery:Sendable
    {
        private
        var patches:[Symbol.PackageDependency<PatchVersion>]

        private
        init(patches:[Symbol.PackageDependency<PatchVersion>] = [])
        {
            self.patches = patches
        }
    }
}
extension Unidoc.PinDependenciesQuery
{
    init?(for snapshot:borrowing Unidoc.Snapshot)
    {
        self.init()

        for case (nil, let dependency) in zip(snapshot.pins, snapshot.metadata.dependencies)
        {
            if  let version:PatchVersion = dependency.version.release
            {
                self.patches.append(.init(package: dependency.id, version: version))
            }
        }

        if  self.patches.isEmpty
        {
            return nil
        }
    }
}
extension Unidoc.PinDependenciesQuery:Mongo.PipelineQuery
{
    typealias CollectionOrigin = Unidoc.DB.PackageAliases
    typealias Collation = SimpleCollation
    typealias Iteration = Mongo.SingleBatch<Symbol.PackageDependency<Unidoc.Edition>>

    var hint:Mongo.CollectionIndex? { nil }

    func build(pipeline:inout Mongo.PipelineEncoder)
    {
        //  Lookup the package alias documents by symbol.
        pipeline[stage: .match] = .init
        {
            $0[Unidoc.PackageAlias[.id]] { $0[.in] = self.patches.lazy.map(\.package) }
        }

        let coordinate:Mongo.AnyKeyPath = "_coordinate"
        let patch:Mongo.AnyKeyPath = "_patch"

        //  We are only interested in the coordinate value stored in the alias documents.
        pipeline[stage: .replaceWith] = .init
        {
            $0[Symbol.PackageDependency<Unidoc.Edition>[.package]] = Unidoc.PackageAlias[.id]
            $0[coordinate] = Unidoc.PackageAlias[.coordinate]
        }

        //  Map the coordinates back to the patch versions associated with the original
        //  packages.
        pipeline[stage: .lookup] = .init
        {
            $0[.foreignField] = Symbol.PackageDependency<PatchVersion>[.package]
            $0[.localField] = Symbol.PackageDependency<Unidoc.Edition>[.package]
            $0[.pipeline] = .init { $0[stage: .documents] = self.patches }
            $0[.as] = patch
        }

        pipeline[stage: .unwind] = patch

        pipeline[stage: .set] = .init
        {
            $0[patch] = patch / Symbol.PackageDependency<PatchVersion>[.version]
        }

        let edition:Mongo.AnyKeyPath = "_edition"

        //  Lookup release editions using the package coordinate and patch version.
        pipeline[stage: .lookup] = .init
        {
            let p:Mongo.Variable<Int32> = "p"
            let v:Mongo.Variable<PatchVersion> = "v"

            $0[.from] = Unidoc.DB.Editions.name
            $0[.let] = .init
            {
                $0[let: p] = coordinate
                $0[let: v] = patch
            }
            $0[.pipeline] = .init
            {
                $0[stage: .match] = .init
                {
                    $0[.and]
                    {
                        $0
                        {
                            $0[.expr] { $0[.eq] = (Unidoc.EditionMetadata[.package], p) }
                        }

                        $0
                        {
                            $0[.expr] { $0[.eq] = (Unidoc.EditionMetadata[.patch], v) }
                        }

                        $0 { $0[Unidoc.EditionMetadata[.release]] = true }
                    }
                }
            }
            $0[.as] = edition
        }

        pipeline[stage: .unwind] = edition

        pipeline[stage: .set] = .init
        {
            $0[Symbol.PackageDependency<Unidoc.Edition>[.version]] =
                edition / Unidoc.EditionMetadata[.id]
        }

        //  Lint temporary variables.
        pipeline[stage: .unset] = [coordinate, patch, edition]
    }
}
