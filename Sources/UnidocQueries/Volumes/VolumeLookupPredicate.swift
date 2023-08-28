import MongoQL

public
protocol VolumeLookupPredicate:Equatable, Hashable, Sendable
{
    func stage(_:inout Mongo.PipelineStage, input:Mongo.KeyPath, output:Mongo.KeyPath)
}
