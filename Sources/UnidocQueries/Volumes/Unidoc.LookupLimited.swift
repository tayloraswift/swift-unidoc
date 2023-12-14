import MongoQL
import Unidoc
import UnidocRecords

extension Unidoc
{
    /// A context mode that looks up volumes for the current volume’s dependencies only.
    @frozen public
    enum LookupLimited
    {
    }
}
extension Unidoc.LookupLimited:Unidoc.LookupContext
{
    /// Sets the `output` to an empty array.
    public static
    func groups(_ pipeline:inout Mongo.PipelineEncoder,
        volume _:Mongo.KeyPath,
        vertex _:Mongo.KeyPath,
        output:Mongo.KeyPath)
    {
        pipeline[.set] = .init
        {
            $0[output] = [] as [Never]
        }
    }

    /// Stores the editions of the current volume’s dependencies in `output.volumes`, and
    /// sets `output.scalars` to an empty array.
    public static
    func edges(_ pipeline:inout Mongo.PipelineEncoder,
        volume:Mongo.KeyPath,
        vertex _:Mongo.KeyPath,
        groups _:Mongo.KeyPath,
        output:(scalars:Mongo.KeyPath, volumes:Mongo.KeyPath))
    {
        pipeline[.set] = .init
        {
            let dependencies:Mongo.List<Unidoc.VolumeMetadata.Dependency, Mongo.KeyPath> = .init(
                in: volume / Unidoc.VolumeMetadata[.dependencies])

            $0[output.volumes] = .expr
            {
                $0[.setUnion] = .init
                {
                    $0.expr { $0[.map] = dependencies.map { $0[.pinned] } }
                }
            }
            $0[output.scalars] = [] as [Never]
        }
    }
}
