import BSON
import MongoQL
import SymbolGraphs

extension Mongo.PipelineEncoder
{
    mutating
    func loadUser(matching id:Unidoc.Account, as output:Mongo.AnyKeyPath)
    {
        self[stage: .lookup]
        {
            $0[.from] = Unidoc.DB.Users.name
            $0[.pipeline]
            {
                $0[stage: .match]
                {
                    $0[Unidoc.User[.id]] = id
                }
            }
            $0[.as] = output
        }

        //  Unbox single-element array.
        self[stage: .set] { $0[output] { $0[.first] = output } }
    }

    mutating
    func loadUser(owning package:Mongo.AnyKeyPath, as output:Mongo.AnyKeyPath)
    {
        self[stage: .set]
        {
            $0[output] = package / Unidoc.PackageMetadata[.repo] / Unidoc.PackageRepo[.account]
        }
        self[stage: .lookup]
        {
            $0[.from] = Unidoc.DB.Users.name
            $0[.localField] = output
            $0[.foreignField] = Unidoc.User[.id]
            $0[.as] = output
        }
        //  Unbox single-element array.
        self[stage: .set] { $0[output] { $0[.first] = output } }
    }

    mutating
    func loadEdition(matching predicate:Unidoc.VersionPredicate,
        from package:Mongo.AnyKeyPath,
        into edition:Mongo.AnyKeyPath)
    {
        //  Lookup the latest release of each package.
        self[stage: .lookup]
        {
            $0[.from] = Unidoc.DB.Editions.name
            $0[.localField] = package / Unidoc.PackageMetadata[.id]
            $0[.foreignField] = Unidoc.EditionMetadata[.package]
            $0[.pipeline]
            {
                $0 += predicate
                $0[stage: .limit] = 1
            }
            $0[.as] = edition
        }

        //  Unbox single-element array.
        self[stage: .set] { $0[edition] { $0[.first] = edition } }
    }
}
extension Mongo.PipelineEncoder
{
    mutating
    func loadDependents(
        limit:Int,
        skip:Int = 0,
        from package:Mongo.AnyKeyPath,
        into output:Mongo.AnyKeyPath)
    {
        self[stage: .lookup]
        {
            $0[.from] = Unidoc.DB.PackageDependencies.name
            $0[.localField] = package / Unidoc.PackageMetadata[.id]
            $0[.foreignField] = Unidoc.PackageDependency[.id]
                / Unidoc.Edge<Unidoc.Package>[.target]

            $0[.pipeline]
            {
                $0[stage: .skip] = skip == 0 ? nil : skip
                $0[stage: .limit] = limit

                $0[stage: .replaceWith] = .init
                {
                    $0[Unidoc.PackageDependent[.package]] = Unidoc.PackageDependency[.id]
                        / Unidoc.Edge<Unidoc.Package>[.source]
                    $0[Unidoc.PackageDependent[.edition]] = Unidoc.PackageDependency[.source]
                }

                //  Look up volume metadata, if it exists.
                $0[stage: .lookup]
                {
                    $0[.from] = Unidoc.DB.Volumes.name
                    $0[.localField] = Unidoc.PackageDependent[.edition]
                    $0[.foreignField] = Unidoc.VolumeMetadata[.id]
                    $0[.as] = Unidoc.PackageDependent[.volume]
                }

                //  Unbox single- or zero-element array.
                $0[stage: .set, using: Unidoc.PackageDependent.CodingKey.self]
                {
                    $0[.volume] { $0[.first] = Unidoc.PackageDependent[.volume] }
                }

                //  Look up edition metadata
                $0[stage: .lookup]
                {
                    $0[.from] = Unidoc.DB.Editions.name
                    $0[.localField] = Unidoc.PackageDependent[.edition]
                    $0[.foreignField] = Unidoc.EditionMetadata[.id]
                    $0[.as] = Unidoc.PackageDependent[.edition]
                }
                //  The edition metadata is mandatory.
                $0[stage: .unwind] = Unidoc.PackageDependent[.edition]

                //  Look up package metadata
                $0[stage: .lookup]
                {
                    $0[.from] = Unidoc.DB.Packages.name
                    $0[.localField] = Unidoc.PackageDependent[.package]
                    $0[.foreignField] = Unidoc.PackageMetadata[.id]
                    $0[.as] = Unidoc.PackageDependent[.package]
                }
                //  The package metadata is mandatory.
                $0[stage: .unwind] = Unidoc.PackageDependent[.package]
            }

            $0[.as] = output
        }
    }
}
extension Mongo.PipelineEncoder
{
    mutating
    func loadBranches(
        limit:Int,
        skip:Int = 0,
        from package:Mongo.AnyKeyPath,
        into branches:Mongo.AnyKeyPath)
    {
        let edition:Mongo.AnyKeyPath = Unidoc.VersionState[.edition]
        let volume:Mongo.AnyKeyPath = Unidoc.VersionState[.volume]
        let graph:Mongo.AnyKeyPath = Unidoc.VersionState[.graph]

        self[stage: .lookup]
        {
            $0[.from] = Unidoc.DB.Editions.name
            $0[.localField] = package / Unidoc.PackageMetadata[.id]
            $0[.foreignField] = Unidoc.EditionMetadata[.package]
            $0[.pipeline]
            {
                $0[stage: .match]
                {
                    $0[Unidoc.EditionMetadata[.release]] = false
                    //  This needs to be ``BSON.Null`` and not just `{ $0[.exists] = false }`,
                    //  otherwise it will not use the partial index.
                    $0[Unidoc.EditionMetadata[.semver]] = BSON.Null.init()
                }

                $0[stage: .sort, using: Unidoc.EditionMetadata.CodingKey.self]
                {
                    $0[.name] = (+)
                }

                $0[stage: .skip] = skip == 0 ? nil : skip

                $0[stage: .limit] = limit

                $0[stage: .replaceWith] = .init
                {
                    $0[edition] = Mongo.Pipeline.ROOT
                }

                $0.loadResources(associatedTo: edition / Unidoc.EditionMetadata[.id],
                    volume: volume,
                    graph: graph)
            }
            $0[.as] = branches
        }
    }

    mutating
    func loadTags(
        matching predicate:Unidoc.VersionPredicate,
        limit:Int = 1,
        skip:Int = 0,
        from package:Mongo.AnyKeyPath,
        into tags:Mongo.AnyKeyPath)
    {
        let edition:Mongo.AnyKeyPath = Unidoc.VersionState[.edition]
        let volume:Mongo.AnyKeyPath = Unidoc.VersionState[.volume]
        let graph:Mongo.AnyKeyPath = Unidoc.VersionState[.graph]

        self[stage: .lookup]
        {
            $0[.from] = Unidoc.DB.Editions.name
            $0[.localField] = package / Unidoc.PackageMetadata[.id]
            $0[.foreignField] = Unidoc.EditionMetadata[.package]
            $0[.pipeline]
            {
                $0 += predicate

                $0[stage: .skip] = skip == 0 ? nil : skip

                $0[stage: .limit] = limit

                $0[stage: .replaceWith] = .init
                {
                    $0[edition] = Mongo.Pipeline.ROOT
                }

                $0.loadResources(associatedTo: edition / Unidoc.EditionMetadata[.id],
                    volume: volume,
                    graph: graph)
            }
            $0[.as] = tags
        }
    }

    /// Load information about any associated documentation volume or symbol graph for a
    /// particular package edition.
    mutating
    func loadResources(associatedTo id:Mongo.AnyKeyPath,
        volume:Mongo.AnyKeyPath,
        graph:Mongo.AnyKeyPath)
    {
        //  Check if a volume has been created for this edition.
        self[stage: .lookup]
        {
            $0[.from] = Unidoc.DB.Volumes.name
            $0[.localField] = id
            $0[.foreignField] = Unidoc.VolumeMetadata[.id]
            $0[.as] = volume
        }

        //  Check if a symbol graph has been uploaded for this edition.
        self[stage: .lookup]
        {
            $0[.from] = Unidoc.DB.Snapshots.name
            $0[.localField] = id
            $0[.foreignField] = Unidoc.Snapshot[.id]
            $0[.pipeline]
            {
                $0[stage: .replaceWith] = .init(Unidoc.VersionState.Graph.CodingKey.self)
                {
                    $0[.id] = Unidoc.Snapshot[.id]
                    $0[.inlineBytes] = .expr
                    {
                        $0[.objectSize] = .expr
                        {
                            $0[.coalesce] = (Unidoc.Snapshot[.inline], BSON.Null.init())
                        }
                    }
                    $0[.remoteBytes] = .expr
                    {
                        $0[.coalesce] = (Unidoc.Snapshot[.size], 0)
                    }
                    $0[.action] = Unidoc.Snapshot[.action]
                    $0[.commit] = Unidoc.Snapshot[.metadata] / SymbolGraphMetadata[.commit_hash]
                    $0[.abi] = Unidoc.Snapshot[.metadata] / SymbolGraphMetadata[.abi]
                }
            }
            $0[.as] = graph
        }

        //  Unbox single-element arrays.
        self[stage: .set]
        {
            $0[volume] { $0[.first] = volume }
            $0[graph] { $0[.first] = graph }
        }
    }
}
