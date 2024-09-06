import MongoQL
import SymbolGraphs
import Symbols
import UnidocDB
import UnidocRecords

extension Unidoc
{
    public
    enum CompleteBuildsPageSegment:PackagePageSegment
    {
        public
        typealias Item = CompleteBuild

        public static
        func bridge(pipeline self:inout Mongo.PipelineEncoder,
            limit:Int,
            skip:Int = 0,
            from package:Mongo.AnyKeyPath,
            into output:Mongo.AnyKeyPath)
        {
            self[stage: .lookup]
            {
                $0[.from] = DB.CompleteBuilds.name
                $0[.localField] = package / PackageMetadata[.id]
                $0[.foreignField] = CompleteBuild[.package]

                $0[.pipeline]
                {
                    $0[stage: .sort, using: CompleteBuild.CodingKey.self]
                    {
                        $0[.finished] = (-)
                    }
                    $0[stage: .skip] = skip == 0 ? nil : skip
                    $0[stage: .limit] = limit
                }

                $0[.as] = output
            }
        }
    }
}
