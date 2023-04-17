import SymbolDescriptions

extension Compiler
{
    @frozen public
    struct Location:Equatable, Hashable, Sendable
    {
        public
        let position:SymbolGraph.Location.Position
        public
        let file:FileIdentifier

        init(position:SymbolGraph.Location.Position, file:FileIdentifier)
        {
            self.position = position
            self.file = file
        }
    }
}
extension Compiler.Location:CustomStringConvertible
{
    public
    var description:String
    {
        "\(self.file):\(self.position.line):\(self.position.column)"
    }
}
