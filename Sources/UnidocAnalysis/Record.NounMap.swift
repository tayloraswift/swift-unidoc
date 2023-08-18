import BSONDecoding
import BSONEncoding
import MD5
import ModuleGraphs
import SymbolGraphs
import Unidoc
import UnidocRecords

extension Record
{
    @frozen public
    struct NounMap:Identifiable, Sendable
    {
        public
        let id:Unidoc.Zone
        public
        let json:JSON

        @inlinable internal
        init(id:Unidoc.Zone, json:JSON)
        {
            self.id = id
            self.json = json
        }
    }
}
extension Record.NounMap
{
    init(id:Unidoc.Zone,
        from trees:__shared [Record.NounTree],
        for modules:__shared [Unidoc.Scalar: ModuleIdentifier])
    {
        let json:JSON = .array
        {
            for tree:Record.NounTree in trees
            {
                guard let culture:ModuleIdentifier = modules[tree.id]
                else
                {
                    continue
                }

                $0[+, Any.self]
                {
                    $0["c"] = "\(culture)"
                    $0["n"]
                    {
                        for row:Record.Noun in tree.rows
                        {
                            $0[+, Any.self]
                            {
                                $0["s"] = row.shoot.stem.rawValue
                                $0["h"] = row.shoot.hash?.value
                            }
                        }
                    }
                }
            }
        }

        self.init(id: id, json: json)
    }
}
extension Record.NounMap
{
    public
    enum CodingKey:String
    {
        case id = "_id"
        /// Contains JSON, encoded as a UTF-8 string.
        case json = "J"
        /// Never decoded from the database.
        case hash = "H"
    }
}
extension Record.NounMap:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id
        bson[.json] = BSON.UTF8View<[UInt8]>.init(slice: self.json.utf8)
        bson[.hash] = MD5.init(hashing: self.json.utf8)
    }
}
extension Record.NounMap:BSONDocumentDecodable
{
    @inlinable public
    init<Bytes>(bson:BSON.DocumentDecoder<CodingKey, Bytes>) throws
    {
        self.init(id: try bson[.id].decode(),
            json: try bson[.json].decode(as: BSON.UTF8View<Bytes.SubSequence>.self)
        {
            JSON.init(utf8: [UInt8].init($0.slice))
        })
    }
}
