import BSON
import MongoQL
import UnidocDB

extension Unidoc
{
    @frozen public
    struct PackageOutput:Sendable
    {
        public
        let metadata:PackageMetadata
        public
        let release:EditionMetadata?

        @inlinable public
        init(metadata:PackageMetadata, release:EditionMetadata?)
        {
            self.metadata = metadata
            self.release = release
        }
    }
}
extension Unidoc.PackageOutput:MongoMasterCodingModel
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case metadata
        case release
    }
}
extension Unidoc.PackageOutput:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(
            metadata: try bson[.metadata].decode(),
            release: try bson[.release]?.decode())
    }
}
extension Unidoc.PackageOutput
{
    static
    func extend(pipeline:inout Mongo.PipelineEncoder, from metadata:some BSONEncodable)
    {
        pipeline[.replaceWith] = .init
        {
            $0[Unidoc.PackageOutput[.metadata]] = Mongo.Pipeline.ROOT
        }

        //  Lookup the latest release of each package.
        pipeline[.lookup] = .init
        {
            $0[.from] = Unidoc.DB.Editions.name
            $0[.localField] = Unidoc.PackageOutput[.metadata] /
                Unidoc.PackageMetadata[.id]
            $0[.foreignField] = Unidoc.EditionMetadata[.package]
            $0[.pipeline] = .init
            {
                $0[.match] = .init
                {
                    $0[Unidoc.EditionMetadata[.release]] = true
                }
                $0[.sort] = .init
                {
                    $0[Unidoc.EditionMetadata[.patch]] = (-)
                    $0[Unidoc.EditionMetadata[.version]] = (-)
                }
                $0[.limit] = 1
            }
            $0[.as] = Unidoc.PackageOutput[.release]
        }

        //  Unbox single-element array.
        pipeline[.set] = .init
        {
            $0[Unidoc.PackageOutput[.release]] = .expr
            {
                $0[.first] = Unidoc.PackageOutput[.release]
            }
        }
    }
}
