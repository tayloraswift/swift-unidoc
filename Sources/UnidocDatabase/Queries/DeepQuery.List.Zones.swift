import BSONEncoding
import MongoBuiltins
import MongoExpressions
import UnidocRecords

extension DeepQuery.List<Record.Extension>
{
    struct Zones
    {
        let extensions:DeepQuery.List<Record.Extension>

        init(_ extensions:DeepQuery.List<Record.Extension>)
        {
            self.extensions = extensions
        }
    }
}
extension DeepQuery.List<Record.Extension>.Zones
{
    static
    func += (list:inout BSON.ListEncoder, self:Self)
    {
        list.expr { $0[.reduce] = self.extensions.join(\.zones) }
    }
}
