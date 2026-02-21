import MongoDB
import Symbols
import UnidocAPI
import UnidocDB

extension Unidoc {
    struct RefStateSymbolicQuery {
        let package: Symbol.Package
        let version: VersionPredicate

        init(package: Symbol.Package, version: VersionPredicate) {
            self.package = package
            self.version = version
        }
    }
}
extension Unidoc.RefStateSymbolicQuery: Unidoc.AliasingQuery {
    typealias Iteration = Mongo.Single<Unidoc.RefState>
    typealias CollectionOrigin = Unidoc.DB.PackageAliases
    typealias CollectionTarget = Unidoc.DB.Packages

    var symbol: Symbol.Package { self.package }

    static var target: Mongo.AnyKeyPath { Unidoc.RefState[.package] }

    func extend(pipeline: inout Mongo.PipelineEncoder) {
        pipeline.loadTags(
            matching: self.version,
            from: Unidoc.RefState[.package],
            into: Unidoc.RefState[.version]
        )

        //  Unbox single-element array.
        pipeline[stage: .unwind] = Unidoc.RefState[.version]

        pipeline.loadUser(
            owning: Unidoc.RefState[.package],
            as: Unidoc.RefState[.owner]
        )

        Unidoc.CompleteBuildsPageSegment.bridge(
            pipeline: &pipeline,
            limit: 1,
            from: Self.target,
            into: Unidoc.RefState[.built]
        )

        pipeline[stage: .lookup] {
            $0[.from] = Unidoc.DB.PendingBuilds.name
            $0[.localField] = Unidoc.RefState[.version]
                / Unidoc.VersionState[.edition]
                / Unidoc.EditionMetadata[.id]

            $0[.foreignField] = Unidoc.PendingBuild[.id]
            $0[.as] = Unidoc.RefState[.build]
        }

        pipeline[stage: .set, using: Unidoc.RefState.CodingKey.self] {
            $0[.build] { $0[.first] = Unidoc.RefState[.build] }
            $0[.built] { $0[.first] = Unidoc.RefState[.built] }
        }
    }
}
