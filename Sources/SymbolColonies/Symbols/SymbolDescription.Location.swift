import JSONDecoding

extension SymbolDescription
{
    @frozen public
    struct Location:Equatable, Hashable, Sendable
    {
        public
        let file:String
        public
        let line:Int 
        public
        let column:Int

        @inlinable public
        init(file:String, line:Int, column:Int)
        {
            self.file = file
            self.line = line
            self.column = column
        }
    }
}
extension SymbolDescription.Location:JSONObjectDecodable
{
    public
    enum CodingKeys:String
    {
        case uri
        case position
        enum Position:String
        {
            case line
            case column = "character"
        }
    }

    public
    init(json:JSON.ObjectDecoder<CodingKeys>) throws
    {
        let (line, column):(Int, Int) = try json[.position].decode(
            using: CodingKeys.Position.self)
        {
            (try $0[.line].decode(), try $0[.column].decode())
        }
        self.init(file: try json[.uri].decode(), line: line, column: column)
    }
}
