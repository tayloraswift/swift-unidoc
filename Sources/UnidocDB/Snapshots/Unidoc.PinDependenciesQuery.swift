import MongoQL
import SemanticVersions
import SymbolGraphs
import Symbols
import UnidocRecords

extension Unidoc {
    struct PinDependenciesQuery: Sendable {
        private(set) var patches: [Symbol.PackageDependency<PatchVersion>]

        private init(patches: [Symbol.PackageDependency<PatchVersion>] = []) {
            self.patches = patches
        }
    }
}
extension Unidoc.PinDependenciesQuery {
    init?(for snapshot: borrowing Unidoc.Snapshot, locally local: Bool) {
        self.init()

        /// To link against versioned documentation, a snapshot must itself be versioned!
        let localOverride: PatchVersion? = local ? .max : nil

        for dependency: SymbolGraphMetadata.Dependency in snapshot.metadata.dependencies {
            if  let localOverride: PatchVersion {
                let exonym: Symbol.Package = dependency.package.name
                self.patches.append(.init(package: exonym, version: localOverride))
            } else if
                let version: PatchVersion = dependency.version.release {
                self.patches.append(.init(package: dependency.id, version: version))
            }
        }

        if  self.patches.isEmpty {
            return nil
        }
    }
}
extension Unidoc.PinDependenciesQuery: Mongo.PipelineQuery {
    typealias Iteration = Mongo.SingleBatch<Symbol.PackageDependency<Unidoc.EditionMetadata>>

    var collation: Mongo.Collation { .simple }
    var from: Mongo.Collection? { Unidoc.DB.PackageAliases.name }
    var hint: Mongo.CollectionIndex? { nil }

    func build(pipeline: inout Mongo.PipelineEncoder) {
        //  Lookup the package alias documents by symbol.
        pipeline[stage: .match] {
            $0[Unidoc.PackageAlias[.id]] { $0[.in] = self.patches.lazy.map(\.package) }
        }

        let coordinate: Mongo.AnyKeyPath = "_coordinate"
        let patch: Mongo.AnyKeyPath = "_patch"

        //  We are only interested in the coordinate value stored in the alias documents.
        pipeline[stage: .replaceWith] {
            $0[Output[.package]] = Unidoc.PackageAlias[.id]
            $0[coordinate] = Unidoc.PackageAlias[.coordinate]
        }

        //  Map the coordinates back to the patch versions associated with the original
        //  packages.
        //
        //  https://www.mongodb.com/docs/manual/reference/operator/aggregation/documents/#use-a--documents-stage-in-a--lookup-stage
        pipeline[stage: .lookup] {
            $0[.foreignField] = Symbol.PackageDependency<PatchVersion>[.package]
            $0[.localField] = Output[.package]
            $0[.pipeline] { $0[stage: .documents] = self.patches }
            $0[.as] = patch
        }

        pipeline[stage: .unwind] = patch

        pipeline[stage: .set] {
            $0[patch] = patch / Symbol.PackageDependency<PatchVersion>[.version]
        }

        //  Lookup release editions using the package coordinate and patch version.
        pipeline[stage: .lookup] {
            let p: Mongo.Variable<Int32> = "p"
            let v: Mongo.Variable<PatchVersion> = "v"

            $0[.from] = Unidoc.DB.Editions.name
            $0[.let] {
                $0[let: p] = coordinate
                $0[let: v] = patch
            }
            $0[.pipeline] {
                $0[stage: .match] {
                    $0[.and] {
                        $0 {
                            $0[.expr] { $0[.eq] = (Unidoc.EditionMetadata[.package], p) }
                        }

                        $0 {
                            $0[.expr] { $0[.eq] = (Unidoc.EditionMetadata[.semver], v) }
                        }

                        $0 { $0[Unidoc.EditionMetadata[.semver]] { $0[.exists] = true } }
                        $0 { $0[Unidoc.EditionMetadata[.release]] = true }
                    }
                }
            }
            $0[.as] = Output[.version]
        }
        //  Lint temporary variables.
        pipeline[stage: .unset] = [coordinate, patch]
        //  Unwind single-element array.
        pipeline[stage: .unwind] = Output[.version]
    }
}
