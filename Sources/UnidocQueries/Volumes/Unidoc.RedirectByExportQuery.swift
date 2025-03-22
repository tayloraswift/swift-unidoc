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
        let vertex:VertexPath

        init(volume:Edition, vertex:VertexPath)
        {
            self.volume = volume
            self.vertex = vertex
        }
    }
}
extension Unidoc.RedirectByExportQuery:Mongo.PipelineQuery
{
    typealias Iteration = Mongo.Single<Unidoc.RedirectOutput>

    var collation:Mongo.Collation { .casefolding }
    var from:Mongo.Collection? { Unidoc.DB.Redirects.name }
    var hint:Mongo.CollectionIndex? { nil }

    func build(pipeline:inout Mongo.PipelineEncoder)
    {
        pipeline[stage: .match]
        {
            $0[Unidoc.RedirectVertex[.id] / Unidoc.RedirectSource[.volume]] = self.volume
            $0[Unidoc.RedirectVertex[.id] / Unidoc.RedirectSource[.stem]] = self.vertex.stem
            $0[Unidoc.RedirectVertex[.id] / Unidoc.RedirectSource[.hash]] = self.vertex.hash
        }

        pipeline[stage: .limit] = 1

        //  De-optionalize the `volume` field.
        pipeline[stage: .set]
        {
            $0[Unidoc.RedirectVertex[.volume]]
            {
                $0[.coalesce] = (Unidoc.RedirectVertex[.volume], self.volume)
            }
        }

        pipeline[stage: .lookup]
        {
            $0[.from] = Unidoc.DB.Volumes.name
            $0[.localField] = Unidoc.RedirectVertex[.volume]
            $0[.foreignField] = Unidoc.VolumeMetadata[.id]
            $0[.as] = Output[.volume]
        }

        pipeline[stage: .unwind] = Unidoc.RedirectOutput[.volume]

        pipeline[stage: .lookup]
        {
            $0[.from] = Unidoc.DB.Vertices.name
            $0[.localField] = Unidoc.RedirectVertex[.target]
            $0[.foreignField] = Unidoc.AnyVertex[.id]
            $0[.as] = Output[.matches]
        }
    }
}
