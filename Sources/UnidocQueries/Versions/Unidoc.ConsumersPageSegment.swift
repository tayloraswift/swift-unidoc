import MongoQL
import SymbolGraphs
import Symbols
import UnidocDB
import UnidocRecords

extension Unidoc {
    public enum ConsumersPageSegment: PackagePageSegment {
        public typealias Item = PackageDependent

        public static func bridge(
            pipeline self: inout Mongo.PipelineEncoder,
            limit: Int,
            skip: Int = 0,
            from package: Mongo.AnyKeyPath,
            into output: Mongo.AnyKeyPath
        ) {
            self[stage: .lookup] {
                $0[.from] = DB.PackageDependencies.name
                $0[.localField] = package / PackageMetadata[.id]
                $0[.foreignField] = PackageDependency[.id] / Edge<Package>[.target]

                $0[.pipeline] {
                    $0[stage: .skip] = skip == 0 ? nil : skip
                    $0[stage: .limit] = limit

                    $0[stage: .replaceWith, using: PackageDependent.CodingKey.self] {
                        $0[.packageRef] = PackageDependency[.targetRef]
                        $0[.package] = PackageDependency[.id] / Edge<Package>[.source]
                        $0[.edition] = PackageDependency[.source]
                    }

                    //  Look up volume metadata, if it exists.
                    $0[stage: .lookup] {
                        $0[.from] = DB.Volumes.name
                        $0[.localField] = PackageDependent[.edition]
                        $0[.foreignField] = VolumeMetadata[.id]
                        $0[.as] = PackageDependent[.volume]
                    }

                    //  Unbox single- or zero-element array.
                    $0[stage: .set, using: PackageDependent.CodingKey.self] {
                        $0[.volume] { $0[.first] = PackageDependent[.volume] }
                    }

                    //  Look up edition metadata
                    $0[stage: .lookup] {
                        $0[.from] = DB.Editions.name
                        $0[.localField] = PackageDependent[.edition]
                        $0[.foreignField] = EditionMetadata[.id]
                        $0[.as] = PackageDependent[.edition]
                    }
                    //  The edition metadata is mandatory.
                    $0[stage: .unwind] = PackageDependent[.edition]

                    //  Look up package metadata
                    $0[stage: .lookup] {
                        $0[.from] = DB.Packages.name
                        $0[.localField] = PackageDependent[.package]
                        $0[.foreignField] = PackageMetadata[.id]
                        $0[.as] = PackageDependent[.package]
                    }
                    //  The package metadata is mandatory.
                    $0[stage: .unwind] = PackageDependent[.package]
                }

                $0[.as] = output
            }
        }
    }
}
