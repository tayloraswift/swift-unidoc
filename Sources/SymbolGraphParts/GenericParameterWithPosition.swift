import JSONDecoding
import Signatures

struct GenericParameterWithPosition
{
    let depth:UInt
    let index:Int
    let name:String
}
extension GenericParameterWithPosition
{
    var parameter:GenericParameter { .init(name: self.name, depth: self.depth) }
    var position:(UInt, Int) { (self.depth, self.index) }
}
extension GenericParameterWithPosition:JSONObjectDecodable
{
    enum CodingKey:String, Sendable
    {
        case name
        case depth
        case index
    }

    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        self.init(
            depth: try json[.depth].decode(),
            index: try json[.index].decode(),
            name: try json[.name].decode())
    }
}
