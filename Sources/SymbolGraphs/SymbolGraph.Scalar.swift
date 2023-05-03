import Availability
import BSONDecoding
import BSONEncoding
import Declarations
import LexicalPaths
import SourceMaps

extension SymbolGraph
{
    @frozen public
    struct Scalar
    {
        public
        let virtuality:ScalarVirtuality?
        public
        let phylum:ScalarPhylum
        public
        let path:LexicalPath

        public
        var declaration:Declaration<ScalarAddress>
        public
        var location:SourceLocation<FileAddress>?

        public
        var article:Article?

        @inlinable public
        init(virtuality:ScalarVirtuality?, phylum:ScalarPhylum, path:LexicalPath)
        {
            self.virtuality = virtuality
            self.phylum = phylum
            self.path = path

            self.declaration = .init()

            self.location = nil
            self.article = nil
        }
    }
}
extension SymbolGraph.Scalar
{
    @frozen public
    enum CodingKeys:String
    {
        case article = "A"

        case availability = "V"
        case abridged = "B"
        case expanded = "E"
        case genericConstraints = "C"
        case genericParameters = "G"

        case flags = "F"
        case path = "P"
        case location = "L"
        case superforms = "S"
    }
}
