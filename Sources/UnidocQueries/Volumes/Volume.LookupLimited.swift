import MongoQL
import Unidoc
import UnidocRecords

extension Volume
{
    /// A context mode that looks up volumes for the current volume’s dependencies only.
    @frozen public
    enum LookupLimited
    {
    }
}
extension Volume.LookupLimited:Volume.LookupContext
{
    /// Sets the `output` to an empty array.
    public static
    func groups(_ stage:inout Mongo.PipelineStage,
        volume _:Mongo.KeyPath,
        vertex _:Mongo.KeyPath,
        output:Mongo.KeyPath)
    {
        stage[.set] = .init
        {
            $0[output] = [] as [Never]
        }
    }

    /// Stores the editions of the current volume’s dependencies in `output.volumes`, and
    /// sets `output.scalars` to an empty array.
    public static
    func edges(_ stage:inout Mongo.PipelineStage,
        volume:Mongo.KeyPath,
        vertex _:Mongo.KeyPath,
        groups _:Mongo.KeyPath,
        output:(scalars:Mongo.KeyPath, volumes:Mongo.KeyPath))
    {
        stage[.set] = .init
        {
            let dependencies:Mongo.List<Volume.Meta.Dependency, Mongo.KeyPath> = .init(
                in: volume / Volume.Meta[.dependencies])

            $0[output.volumes] = .expr
            {
                $0[.setUnion] = .init
                {
                    $0.expr { $0[.map] = dependencies.map { $0[.resolution] } }
                }
            }
            $0[output.scalars] = [] as [Never]
        }
    }
}
