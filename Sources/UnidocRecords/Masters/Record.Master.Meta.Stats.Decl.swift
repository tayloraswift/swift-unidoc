import BSONDecoding
import BSONEncoding
import LexicalPaths
import SymbolGraphs
import Unidoc

extension Record.Master.Meta.Stats
{
    @frozen public
    struct Decl:Equatable, Sendable
    {
        /// Typealiases.
        public
        var typealiases:Int
        /// Structs and enums.
        public
        var structures:Int
        /// Protocols.
        public
        var protocols:Int
        /// Classes, excluding actors.
        public
        var classes:Int
        /// Actors.
        public
        var actors:Int

        /// Protocol requirements, including associated types.
        public
        var requirements:Int
        /// Default implementations.
        public
        var witnesses:Int

        /// Initializers, static/class funcs, static/class subscripts, static/class vars, and
        /// enum cases. Does not include requirements or default implementations.
        public
        var constructors:Int
        /// Instance subscripts. Does not include requirements or default implementations.
        public
        var subscripts:Int
        /// Instance functions named `callAsFunction`. Does not include requirements or default
        /// implementations.
        public
        var functors:Int
        /// Deinitializers, instance funcs and instance vars, unless they are named
        /// `callAsFunction`. Does not include requirements or default implementations.
        public
        var methods:Int

        /// Operators.
        public
        var operators:Int
        /// Global funcs and vars.
        public
        var functions:Int

        @inlinable public
        init(
            typealiases:Int,
            structures:Int,
            protocols:Int,
            classes:Int,
            actors:Int,
            requirements:Int,
            witnesses:Int,
            constructors:Int,
            subscripts:Int,
            functors:Int,
            methods:Int,
            operators:Int,
            functions:Int)
        {
            self.typealiases = typealiases
            self.structures = structures
            self.protocols = protocols
            self.classes = classes
            self.actors = actors
            self.requirements = requirements
            self.witnesses = witnesses
            self.constructors = constructors
            self.subscripts = subscripts
            self.functors = functors
            self.methods = methods
            self.operators = operators
            self.functions = functions
        }
    }
}
extension Record.Master.Meta.Stats.Decl:ExpressibleByDictionaryLiteral
{
    @inlinable public
    init(dictionaryLiteral elements:(Never, Int)...)
    {
        self.init(
            typealiases: 0,
            structures: 0,
            protocols: 0,
            classes: 0,
            actors: 0,
            requirements: 0,
            witnesses: 0,
            constructors: 0,
            subscripts: 0,
            functors: 0,
            methods: 0,
            operators: 0,
            functions: 0)
    }
}
extension Record.Master.Meta.Stats.Decl
{
    @inlinable public mutating
    func count(_ decl:SymbolGraph.Decl)
    {
        if  decl.kinks[is: .required]
        {
            self.requirements += 1
            return
        }
        if  decl.kinks[is: .intrinsicWitness]
        {
            self.witnesses += 1
            return
        }
        if  case .func(.instance?) = decl.phylum,
            decl.path.last.prefix(while: { $0 != "(" }) == "callAsFunction"
        {
            self.functors += 1
            return
        }

        switch decl.phylum
        {
        case    .associatedtype:        self.requirements += 1
        case    .typealias:             self.typealiases += 1
        case    .struct,
                .enum:                  self.structures += 1
        case    .protocol:              self.protocols += 1
        case    .class:                 self.classes += 1
        case    .actor:                 self.actors += 1
        case    .initializer,
                .subscript(.static),
                .subscript(.class),
                .func(.static?),
                .func(.class?),
                .var(.static?),
                .var(.class?),
                .case:                  self.constructors += 1
        case    .subscript(.instance):  self.subscripts += 1
        case    .deinitializer,
                .func(.instance?),
                .var(.instance?):       self.methods += 1
        case    .operator:              self.operators += 1
        case    .func(nil),
                .var(nil):              self.functions += 1
        }
    }
}
extension Record.Master.Meta.Stats.Decl
{
    public
    enum CodingKey:String
    {
        case typealiases = "T"
        case structures = "V"
        case protocols = "P"
        case classes = "O"
        case actors = "A"
        case requirements = "R"
        case witnesses = "D"
        case constructors = "N"
        case subscripts = "S"
        case functors = "C"
        case methods = "M"
        case operators = "X"
        case functions = "F"
    }
}
extension Record.Master.Meta.Stats.Decl:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.typealiases]  = self.typealiases  != 0 ? self.typealiases : nil
        bson[.structures]   = self.structures   != 0 ? self.structures : nil
        bson[.protocols]    = self.protocols    != 0 ? self.protocols : nil
        bson[.classes]      = self.classes      != 0 ? self.classes : nil
        bson[.actors]       = self.actors       != 0 ? self.actors : nil
        bson[.requirements] = self.requirements != 0 ? self.requirements : nil
        bson[.witnesses]    = self.witnesses    != 0 ? self.witnesses : nil
        bson[.constructors] = self.constructors != 0 ? self.constructors : nil
        bson[.subscripts]   = self.subscripts   != 0 ? self.subscripts : nil
        bson[.functors]     = self.functors     != 0 ? self.functors : nil
        bson[.methods]      = self.methods      != 0 ? self.methods : nil
        bson[.operators]    = self.operators    != 0 ? self.operators : nil
        bson[.functions]    = self.functions    != 0 ? self.functions : nil
    }
}
extension Record.Master.Meta.Stats.Decl:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(
            typealiases: try bson[.typealiases]?.decode() ?? 0,
            structures: try bson[.structures]?.decode() ?? 0,
            protocols: try bson[.protocols]?.decode() ?? 0,
            classes: try bson[.classes]?.decode() ?? 0,
            actors: try bson[.actors]?.decode() ?? 0,
            requirements: try bson[.requirements]?.decode() ?? 0,
            witnesses: try bson[.witnesses]?.decode() ?? 0,
            constructors: try bson[.constructors]?.decode() ?? 0,
            subscripts: try bson[.subscripts]?.decode() ?? 0,
            functors: try bson[.functors]?.decode() ?? 0,
            methods: try bson[.methods]?.decode() ?? 0,
            operators: try bson[.operators]?.decode() ?? 0,
            functions: try bson[.functions]?.decode() ?? 0)
    }
}
