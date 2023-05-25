import Generics
import Symbols
import SymbolGraphParts

extension Compiler
{
    /// A shareable reference to a scalar value.
    ///
    /// This reference type is useful because we want to be able to query
    /// things about the existence or knowledge of a scalar, and then
    /// separately write updates to the scalar without looking it up again.
    final
    class ScalarObject
    {
        let conditions:[GenericConstraint<ScalarSymbol>]
        let culture:Int

        /// The type of the superforms tracked by ``\.value.superforms``.
        var superforms:(any SuperformRelationship.Type)?
        /// The symbol this scalar is lexically-nested in. This may
        /// be an extension block symbol.
        var scope:UnifiedSymbol?

        private(set)
        var value:Scalar

        init(conditions:[GenericConstraint<ScalarSymbol>],
            culture:Int,
            value:Scalar)
        {
            self.conditions = conditions
            self.culture = culture

            self.superforms = nil
            self.scope = nil

            self.value = value
        }
    }
}
extension Compiler.ScalarObject
{
    var id:ScalarSymbol
    {
        self.value.id
    }
}
extension Compiler.ScalarObject
{
    /// Assigns an origin to this scalar object.
    func assign(origin:ScalarSymbol) throws
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

        //  Allowed to restate the exact same nesting relationship multiple times.
        //  This sometimes happens when compiling C modules.
        if  let scope:UnifiedSymbol = self.scope,
                scope != nesting.scope
        {
            throw Compiler.NestingError.conflict(with: scope)
        }
        else
        {
            self.scope = nesting.scope
        }

        if  let aperture:ScalarAperture = nesting.aperture
        {
            self.value.aperture = aperture
        }
        if  let origin:ScalarSymbol = nesting.origin
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
        if  let origin:ScalarSymbol = superform.origin
        {
            try self.assign(origin: origin)
        }
    }
    /// Adds an *unqualified* feature to this scalar object.
    ///
    /// If you know the feature’s extension constraints, add it
    /// to an appropriate ``ExtensionObject`` instead.
    func add(feature:ScalarSymbol, where unknown:Never?)
    {
        self.value.features.insert(feature)
    }
}
