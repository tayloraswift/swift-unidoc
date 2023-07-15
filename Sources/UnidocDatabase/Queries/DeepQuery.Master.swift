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
    var scalars:Scalars { .init(self) }

    subscript(keypath:BSON.Key) -> String
    {
        "$\(self.key / keypath)"
    }
}
