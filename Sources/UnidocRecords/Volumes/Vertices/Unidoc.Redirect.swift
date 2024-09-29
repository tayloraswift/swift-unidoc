import BSON

extension Unidoc
{
    @frozen public
    struct Redirect:Hashable, Sendable
    {
        public
        let volume:Edition
        public
        let target:Scalar

        @inlinable public
        init(volume:Edition, target:Scalar)
        {
            self.volume = volume
            self.target = target
        }
    }
}
extension Unidoc.Redirect
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case volume = "V"
        case target = "T"
    }
}
extension Unidoc.Redirect:BSONDocumentEncodable
{
    public
    func encode(to document:inout BSON.DocumentEncoder<CodingKey>)
    {
        document[.volume] = self.volume
        document[.target] = self.target
    }
}
extension Unidoc.Redirect:BSONDocumentDecodable
{
    public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(volume: try bson[.volume].decode(), target: try bson[.target].decode())
    }
}
