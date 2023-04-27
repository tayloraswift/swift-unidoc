import Generics
import SymbolGraphParts

extension Compiler
{
    /// A shareable reference to a scalar value.
    ///
    /// This reference type is useful because we want to be able to query
    /// things about the existence or knowledge of a scalar, and then
    /// separately write updates to the scalar without looking it up again.
    final
    class ScalarReference
    {
        let conditions:[GenericConstraint<Symbol.Scalar>]

        /// The type of the superforms tracked by ``\.value.superforms``.
        var superforms:(any SuperformRelationship.Type)?
        /// The symbol this scalar is lexically-nested in. This may
        /// be an extension block symbol.
        var scope:Symbol?

        private(set)
        var value:Scalar

        init(conditions:[GenericConstraint<Symbol.Scalar>],
            value:Scalar)
        {
            self.conditions = conditions

            self.superforms = nil
            self.scope = nil

            self.value = value
        }
    }
}
extension Compiler.ScalarReference
{
    var resolution:Symbol.Scalar
    {
        self.value.resolution
    }
}
extension Compiler.ScalarReference
{
    /// Assigns an origin to this scalar object.
    func assign(origin:Symbol.Scalar) throws
    {
        switch self.value.origin
        {
        case nil, origin?:
            self.value.origin = origin
        
        case let other?:
            throw Compiler.OriginError.conflict(with: other)
        }
    }
    /// Assigns a lexical scope to this scalar object.
    func assign(nesting:some NestingRelationship) throws
    {
        guard nesting.validate(source: self.value.phylum)
        else
        {
            throw Compiler.NestingError.phylum(self.value.phylum)
        }

        if  let scope:Symbol = self.scope
        {
            throw Compiler.NestingError.conflict(with: scope)
        }
        else
        {
            self.scope = nesting.scope
        }

        if  let virtuality:ScalarPhylum.Virtuality = nesting.virtuality
        {
            self.value.virtuality = virtuality
        }
        if  let origin:Symbol.Scalar = nesting.origin
        {
            try self.assign(origin: origin)
        }
    }
    /// Adds a superform to this scalar object.
    ///
    /// Each scalar can only accept a single type of superform. For example, if
    /// a scalar is the source of a ``SymbolRelationship DefaultImplementation``
    /// relationship, it can receive additional superforms of that type, but it
    /// cannot receive a ``SymbolRelationship Override``, because a scalar cannot
    /// be a default implementation and a protocol requirement at the same time.
    func add<Superform>(superform:Superform) throws
        where Superform:SuperformRelationship
    {
        guard superform.validate(source: self.value.phylum)
        else
        {
            throw Compiler.SuperformError.phylum(self.value.phylum)
        }

        switch self.superforms
        {
        case nil, (is Superform.Type)?:
            self.value.superforms.insert(superform.target)
            self.superforms = Superform.self
        
        case let type?:
            throw Compiler.SuperformError.conflict(with: type)
        }
        if  let origin:Symbol.Scalar = superform.origin
        {
            try self.assign(origin: origin)
        }
    }
    /// Adds an *unqualified* feature to this scalar object.
    ///
    /// If you know the feature’s extension constraints, add it
    /// to an appropriate ``ExtensionReference`` instead.
    func add(feature:Symbol.Scalar, where unknown:Never?)
    {
        self.value.features.insert(feature)
    }
}
