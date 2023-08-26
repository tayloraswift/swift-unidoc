import MongoQL

extension Optional where Wrapped:StageBuilder
{
    static
    func ?= (pipeline:inout Mongo.Pipeline, self:Self)
    {
        if  let self:Wrapped
        {
            pipeline += self
        }
    }
}
