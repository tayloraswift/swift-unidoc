import MongoQL
import UnidocDB

extension Mongo
{
    struct SingleOutputFromPrimary<Query>
        where   Query:Mongo.PipelineQuery,
                Query.Iteration.Stride == Never,
                Query.Iteration.Batch == Query.Iteration.BatchElement?
    {
        let query:Query
        var value:Query.Iteration.BatchElement?

        init(query:Query)
        {
            self.query = query
            self.value = nil
        }
    }
}
extension Mongo.SingleOutputFromPrimary:Mongo.PipelineEndpoint, Mongo.SingleOutputEndpoint
{
    static
    var replica:Mongo.ReadPreference { .primary }
}
