import UnidocAPI
import MongoQL

extension Unidoc
{
    @frozen public
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
            pipeline[stage: .match] = .init
            {
                $0[Unidoc.EditionMetadata[.release]] = series == .release
                $0[Unidoc.EditionMetadata[.semver]] { $0[.exists] = true }
            }

            pipeline[stage: .sort] = .init
            {
                $0[Unidoc.EditionMetadata[.semver]] = (-)
                $0[Unidoc.EditionMetadata[.version]] = (-)
            }

        case .name(let name):
            pipeline[stage: .match] = .init
            {
                $0[Unidoc.EditionMetadata[.name]] = name
            }
        }
    }
}