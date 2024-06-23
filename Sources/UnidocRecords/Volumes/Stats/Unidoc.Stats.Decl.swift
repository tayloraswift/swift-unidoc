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
extension Unidoc.Stats.Decl
{
    @inlinable public static
    func + (self:consuming Self, other:Self) -> Self
    {
        self += other
        return self
    }

    @inlinable public static
    func += (self:inout Self, other:Self)
    {
        self.typealiases += other.typealiases
        self.structures += other.structures
        self.protocols += other.protocols
        self.classes += other.classes
        self.actors += other.actors
        self.requirements += other.requirements
        self.witnesses += other.witnesses
        self.constructors += other.constructors
        self.subscripts += other.subscripts
        self.functors += other.functors
        self.methods += other.methods
        self.operators += other.operators
        self.functions += other.functions
        self.freestandingMacros += other.freestandingMacros
        self.attachedMacros += other.attachedMacros
    }
}
extension Unidoc.Stats.Decl:ExpressibleByDictionaryLiteral
{
    @inlinable public
    init(dictionaryLiteral elements:(CodingKey, Never)...)
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
extension Unidoc.Stats.Decl:Unidoc.StatsCounters,
    BSONDocumentEncodable,
    BSONDocumentDecodable
{
    @frozen public
    enum CodingKey:String, Sendable, CaseIterable
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

    @inlinable public static
    subscript(key:CodingKey) -> WritableKeyPath<Self, Int>
    {
        switch key
        {
        case .typealiases:          \.typealiases
        case .structures:           \.structures
        case .protocols:            \.protocols
        case .classes:              \.classes
        case .actors:               \.actors
        case .requirements:         \.requirements
        case .witnesses:            \.witnesses
        case .constructors:         \.constructors
        case .subscripts:           \.subscripts
        case .functors:             \.functors
        case .methods:              \.methods
        case .operators:            \.operators
        case .functions:            \.functions
        case .freestandingMacros:   \.freestandingMacros
        case .attachedMacros:       \.attachedMacros
        }
    }
}
