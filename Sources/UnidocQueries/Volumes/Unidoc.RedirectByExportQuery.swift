import FNV1
import MongoDB
import MongoQL
import UnidocAPI
import UnidocDB
import UnidocRecords

extension Unidoc
{
    struct RedirectByExportQuery:Sendable
    {
        let volume:Edition
        let stem:Stem
        let hash:FNV24?

        init(volume:Edition, stem:Stem, hash:FNV24?)
        {
            self.volume = volume
            self.stem = stem
            self.hash = hash
        }
    }
}
extension Unidoc.RedirectByExportQuery:Mongo.PipelineQuery
{
    typealias CollectionOrigin = Unidoc.DB.Redirects
    typealias Collation = VolumeCollation
    typealias Iteration = Mongo.Single<Unidoc.RedirectOutput>

    var hint:Mongo.CollectionIndex? { nil }

    func build(pipeline:inout Mongo.PipelineEncoder)
    {
        pipeline[stage: .match]
        {
            $0[CollectionOrigin.Element[.id] / Unidoc.Redirect[.volume]] = self.volume
            $0[CollectionOrigin.Element[.stem]] = self.stem
            $0[CollectionOrigin.Element[.hash]] = self.hash
        }

        pipeline[stage: .limit] = 1

        //  De-optionalize the `volume` field.
        pipeline[stage: .set]
        {
            $0[CollectionOrigin.Element[.volume]]
            {
                $0[.coalesce] = (CollectionOrigin.Element[.volume], self.volume)
            }
        }

        pipeline[stage: .lookup]
        {
            $0[.from] = Unidoc.DB.Volumes.name
            $0[.localField] = CollectionOrigin.Element[.volume]
            $0[.foreignField] = Unidoc.VolumeMetadata[.id]
            $0[.as] = Iteration.BatchElement[.volume]
        }

        pipeline[stage: .unwind] = Unidoc.RedirectOutput[.volume]

        pipeline[stage: .lookup]
        {
            $0[.from] = Unidoc.DB.Vertices.name
            $0[.localField] = CollectionOrigin.Element[.id] / Unidoc.Redirect[.target]
            $0[.foreignField] = Unidoc.AnyVertex[.id]
            $0[.as] = Iteration.BatchElement[.matches]
        }
    }
}
