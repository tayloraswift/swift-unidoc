import Availability
import BSONDecoding
import BSONEncoding
import Declarations
import Generics
import LexicalPaths
import SourceMaps

extension SymbolGraph
{
    @frozen public
    struct Scalar
    {
        public
        let flags:Flags
        public
        let path:LexicalPath

        public
        var declaration:Declaration<ScalarAddress>
        public
        var location:SourceLocation<FileAddress>?

        public
        var article:Article?

        @inlinable public
        init(flags:Flags, path:LexicalPath)
        {
            self.flags = flags
            self.path = path

            self.declaration = .init()

            self.location = nil
            self.article = nil
        }
    }
}
extension SymbolGraph.Scalar
{
    @inlinable public
    var aperture:ScalarAperture { self.flags.aperture }
    @inlinable public
    var phylum:ScalarPhylum { self.flags.phylum }
}
extension SymbolGraph.Scalar
{
    @frozen public
    enum CodingKeys:String
    {
        case flags = "F"
        case path = "P"
        case location = "L"

        case declaration_availability = "V"
        case declaration_abridged_bytecode = "B"
        case declaration_expanded_bytecode = "E"
        case declaration_expanded_links = "K"
        case declaration_generics_constraints = "C"
        case declaration_generics_parameters = "G"

        case superforms = "S"
        case article = "A"
    }
}
extension SymbolGraph.Scalar:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKeys>)
    {
        bson[.flags] = self.flags
        bson[.path] = self.path.joined(separator: " ")

        bson[.declaration_availability] =
            self.declaration.availability.isEmpty ? nil :
            self.declaration.availability
        
        bson[.declaration_abridged_bytecode] = self.declaration.abridged.bytecode
        bson[.declaration_expanded_bytecode] = self.declaration.expanded.bytecode
        //  TODO: optimize
        bson[.declaration_expanded_links] =
            self.declaration.expanded.links.isEmpty ? nil :
            self.declaration.expanded.links
        
        bson[.declaration_generics_constraints] =
            self.declaration.generics.constraints.isEmpty ? nil :
            self.declaration.generics.constraints

        bson[.declaration_generics_parameters] =
            self.declaration.generics.parameters.isEmpty ? nil :
            self.declaration.generics.parameters
        
        bson[.location] = self.location
        bson[.article] = self.article
    }
}
extension SymbolGraph.Scalar:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKeys, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(
            flags: try bson[.flags].decode(),
            path: try bson[.path].decode())

        self.declaration = .init(
            availability: try bson[.declaration_availability]?.decode() ?? .init(),
            abridged: .init(bytecode: try bson[.declaration_abridged_bytecode].decode()),
            expanded: .init(bytecode: try bson[.declaration_expanded_bytecode].decode()),
            generics: .init(
                constraints: try bson[.declaration_generics_constraints]?.decode() ?? [],
                parameters: try bson[.declaration_generics_parameters]?.decode() ?? []))

        self.location = try bson[.location]?.decode()
        self.article = try bson[.article]?.decode()
    }
}
