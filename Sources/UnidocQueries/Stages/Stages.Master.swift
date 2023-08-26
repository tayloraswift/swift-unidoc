import MongoQL
import Unidoc
import UnidocDatabase
import UnidocSelectors
import UnidocRecords

extension Stages
{
    struct Master<Selector> where Selector:DatabaseLookupSelector
    {
        let selector:Selector
        let output:Mongo.KeyPath
        let input:Mongo.KeyPath

        init(_ selector:Selector, in input:Mongo.KeyPath, as output:Mongo.KeyPath)
        {
            self.selector = selector
            self.output = output
            self.input = input
        }
    }
}
extension Stages.Master:StageBuilder
{
    static
    func += (pipeline:inout Mongo.Pipeline, self:Self)
    {
        pipeline.stage
        {
            $0[.lookup] = self.selector.lookup(input: self.input, as: self.output)
        }
    }
}
