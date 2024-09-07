import MongoQL
import UnidocAPI

extension Unidoc
{
    enum VersionPredicate:Sendable
    {
        case latest(VersionSeries)
        case name(String)
    }
}
extension Unidoc.VersionPredicate
{
    static
    func += (pipeline:inout Mongo.PipelineEncoder, self:Self)
    {
        switch self
        {
        case .latest(let series):
            pipeline[stage: .match]
            {
                $0[Unidoc.EditionMetadata[.release]] = series == .release
                $0[Unidoc.EditionMetadata[.semver]] { $0[.exists] = true }
            }

            pipeline[stage: .sort, using: Unidoc.EditionMetadata.CodingKey.self]
            {
                $0[.semver] = (-)
                $0[.version] = (-)
            }

        case .name(let name):
            pipeline[stage: .match]
            {
                $0[Unidoc.EditionMetadata[.name]] = name
            }
        }
    }
}
