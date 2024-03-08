import MongoQL
import SymbolGraphs
import UnidocDB

extension Unidoc
{
    @frozen public
    struct BuilderQuery
    {
        @usableFromInline
        let edition:Unidoc.Edition

        @inlinable public
        init(edition:Unidoc.Edition)
        {
            self.edition = edition
        }
    }
}
extension Unidoc.BuilderQuery:Mongo.PipelineQuery
{
    public
    typealias CollectionOrigin = Unidoc.DB.Packages
    public
    typealias Collation = SimpleCollation
    public
    typealias Iteration = Mongo.Single<Output>

    public
    var hint:Mongo.CollectionIndex? { nil }

    public
    func build(pipeline:inout Mongo.PipelineEncoder)
    {
        pipeline[stage: .match] = .init
        {
            $0[Unidoc.PackageMetadata[.id]] = self.edition.package
        }
        pipeline[stage: .replaceWith] = .init
        {
            $0[Output[.package]] = Mongo.Pipeline.ROOT
        }

        pipeline[stage: .lookup] = .init
        {
            $0[.from] = Unidoc.DB.Editions.name

            $0[.pipeline] = .init
            {
                $0[stage: .match] = .init
                {
                    $0[Unidoc.EditionMetadata[.id]] = self.edition
                }
            }

            $0[.as] = Output[.edition]
        }

        pipeline[stage: .unwind] = Output[.edition]
    }
}
