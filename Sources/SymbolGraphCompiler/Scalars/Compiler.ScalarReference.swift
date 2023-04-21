import SymbolDescriptions

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
        let conditions:[GenericConstraint<ScalarSymbolResolution>]

        /// The type of the superforms tracked by ``\.value.superforms``.
        var superforms:(any SuperformRelationship.Type)?
        /// The symbol this scalar is lexically-nested in. This may
        /// be an extension block symbol.
        var scope:UnifiedSymbolResolution?

        private(set)
        var value:Scalar

        init(conditions:[GenericConstraint<ScalarSymbolResolution>],
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
    var resolution:ScalarSymbolResolution
    {
        self.value.resolution
    }
}
extension Compiler.ScalarReference
{
    final
    func assign(nesting:some NestingRelationship) throws
    {
        guard nesting.validate(source: self.value.phylum)
        else
        {
            throw Compiler.NestingError.phylum(self.value.phylum)
        }

        if  let scope:UnifiedSymbolResolution = self.scope
        {
            throw Compiler.NestingError.conflict(with: scope)
        }
        else
        {
            self.scope = nesting.scope
        }

        if  let virtuality:SymbolGraph.Scalar.Virtuality = nesting.virtuality
        {
            self.value.virtuality = virtuality
        }
        if  let origin:ScalarSymbolResolution = nesting.origin
        {
            try self.assign(origin: origin)
        }
    }
    final
    func append<Superform>(superform:Superform) throws
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
            self.value.superforms.append(superform.target)
            self.superforms = Superform.self
        
        case let type?:
            throw Compiler.SuperformError.conflict(with: type)
        }
        if  let origin:ScalarSymbolResolution = superform.origin
        {
            try self.assign(origin: origin)
        }
    }
    final
    func assign(origin:ScalarSymbolResolution) throws
    {
        switch self.value.origin
        {
        case nil, origin?:
            self.value.origin = origin
        
        case let other?:
            throw Compiler.OriginError.conflict(with: other)
        }
    }
}
