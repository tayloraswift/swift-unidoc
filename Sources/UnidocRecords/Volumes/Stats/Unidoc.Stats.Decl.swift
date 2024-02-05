import BSON
import LexicalPaths
import SymbolGraphs
import Unidoc

extension Unidoc.Stats
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

        public
        var freestandingMacros:Int
        public
        var attachedMacros:Int

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
            functions:Int,
            freestandingMacros:Int,
            attachedMacros:Int)
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
            self.freestandingMacros = freestandingMacros
            self.attachedMacros = attachedMacros
        }
    }
}
extension Unidoc.Stats.Decl:ExpressibleByDictionaryLiteral
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
            functions: 0,
            freestandingMacros: 0,
            attachedMacros: 0)
    }
}
extension Unidoc.Stats.Decl
{
    @inlinable public
    var total:Int
    {
        self.typealiases
        + self.structures
        + self.protocols
        + self.classes
        + self.actors
        + self.requirements
        + self.witnesses
        + self.constructors
        + self.subscripts
        + self.functors
        + self.methods
        + self.operators
        + self.functions
        + self.freestandingMacros
        + self.attachedMacros
    }
}
extension Unidoc.Stats.Decl
{
    @frozen public
    enum CodingKey:String, Sendable
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
        case freestandingMacros = "Y"
        case attachedMacros = "Z"
    }
}
extension Unidoc.Stats.Decl:BSONDocumentEncodable
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

        bson[.freestandingMacros] =
            self.freestandingMacros != 0 ? self.freestandingMacros : nil
        bson[.attachedMacros] =
            self.attachedMacros != 0 ? self.attachedMacros : nil
    }
}
extension Unidoc.Stats.Decl:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
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
            functions: try bson[.functions]?.decode() ?? 0,
            freestandingMacros: try bson[.freestandingMacros]?.decode() ?? 0,
            attachedMacros: try bson[.attachedMacros]?.decode() ?? 0)
    }
}
