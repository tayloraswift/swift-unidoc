import BSONEncoding

extension DeepQuery
{
    struct Master
    {
        let key:BSON.Key

        init(in key:BSON.Key)
        {
            self.key = key
        }
    }
}
extension DeepQuery.Master
{
    var scalars:Scalars { .init(in: self.key) }
    var zones:Zones { .init(in: self.key) }
}
