import BSON
import MongoQL
import SymbolGraphs

extension Mongo.PipelineEncoder
{
    mutating
    func loadTags(
        series:Unidoc.VersionSeries,
        limit:Int = 1,
        skip:Int = 0,
        from package:Mongo.AnyKeyPath,
        into tags:Mongo.AnyKeyPath)
    {
        let edition:Mongo.AnyKeyPath = Unidoc.Versions.Tag[.edition]
        let volume:Mongo.AnyKeyPath = Unidoc.Versions.Tag[.volume]
        let graph:Mongo.AnyKeyPath = Unidoc.Versions.Tag[.graph]

        self[stage: .lookup] = Mongo.LookupDocument.init
        {
            $0[.from] = Unidoc.DB.Editions.name
            $0[.localField] = package / Unidoc.PackageMetadata[.id]
            $0[.foreignField] = Unidoc.EditionMetadata[.package]
            $0[.pipeline] = .init
            {
                $0[stage: .match] = .init
                {
                    $0[Unidoc.EditionMetadata[.release]] = series == .release
                    $0[Unidoc.EditionMetadata[.release]] { $0[.exists] = true }
                }

                $0[stage: .sort] = .init
                {
                    $0[Unidoc.EditionMetadata[.patch]] = (-)
                    $0[Unidoc.EditionMetadata[.version]] = (-)
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
            $0[.as] = tags
        }
    }

    mutating
    func loadTopOfTree(from package:Mongo.AnyKeyPath, into top:Mongo.AnyKeyPath)
    {
        //  Compute id of local snapshot, if one were to exist.
        let id:Mongo.AnyKeyPath = "_top_id"

        self[stage: .set] = .init
        {
            $0[id] = .expr
            {
                $0[.add] = .init
                {
                    $0.expr
                    {
                        $0[.multiply] =
                        (
                            package / Unidoc.PackageMetadata[.id],
                            0x0000_0001_0000_0000 as Int64
                        )
                    }
                    $0.append(0x0000_0000_ffff_ffff as Int64)
                }
            }
        }

        self.loadResources(associatedTo: id,
            volume: top / Unidoc.Versions.TopOfTree[.volume],
            graph: top / Unidoc.Versions.TopOfTree[.graph])

        self[stage: .unset] = id
    }

    /// Load information about any associated documentation volume or symbol graph for a
    /// particular package edition.
    private mutating
    func loadResources(associatedTo id:Mongo.AnyKeyPath,
        volume:Mongo.AnyKeyPath,
        graph:Mongo.AnyKeyPath)
    {
        //  Check if a volume has been created for this edition.
        self[stage: .lookup] = .init
        {
            $0[.from] = Unidoc.DB.Volumes.name
            $0[.localField] = id
            $0[.foreignField] = Unidoc.VolumeMetadata[.id]
            $0[.as] = volume
        }

        //  Check if a symbol graph has been uploaded for this edition.
        self[stage: .lookup] = Mongo.LookupDocument.init
        {
            $0[.from] = Unidoc.DB.Snapshots.name
            $0[.localField] = id
            $0[.foreignField] = Unidoc.Snapshot[.id]
            $0[.pipeline] = .init
            {
                $0[stage: .replaceWith] = .init(Unidoc.Versions.Graph.CodingKey.self)
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
                    $0[.abi] = Unidoc.Snapshot[.metadata] / SymbolGraphMetadata[.abi]
                }
            }
            $0[.as] = graph
        }

        //  Unbox single-element arrays.
        self[stage: .set] = .init
        {
            $0[volume] = .expr { $0[.first] = volume }
            $0[graph] = .expr { $0[.first] = graph }
        }
    }
}