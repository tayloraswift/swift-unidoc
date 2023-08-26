import MD5
import MongoQL

extension Stages
{
    struct Elision
    {
        let field:Mongo.KeyPath
        let hash:Mongo.KeyPath
        let tag:MD5

        init(field:Mongo.KeyPath, where hash:Mongo.KeyPath, is tag:MD5)
        {
            self.field = field
            self.hash = hash
            self.tag = tag
        }
    }
}
extension Stages.Elision:StageBuilder
{
    static
    func += (pipeline:inout Mongo.Pipeline, self:Self)
    {
        pipeline.stage
        {
            $0[.set] = .init
            {
                $0[self.field] = .expr
                {
                    $0[.cond] =
                    (
                        if: .expr { $0[.eq] = (self.tag, self.hash) },
                        then: .expr
                        {
                            $0[.binarySize] = self.field
                        },
                        else: self.field
                    )
                }
            }
        }
    }
}
