import MongoQL

protocol StageBuilder
{
    static
    func += (pipeline:inout Mongo.Pipeline, self:Self)
}
