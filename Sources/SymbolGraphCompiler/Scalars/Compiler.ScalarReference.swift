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
        final private(set)
        var value:Scalar

        init(value:Scalar)
        {
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

    var conditions:[GenericConstraint<ScalarSymbolResolution>]
    {
        self.value.conditions
    }
}
extension Compiler.ScalarReference
{
    final
    func assign(membership:Compiler.LatticeMembership,
        origin:ScalarSymbolResolution? = nil) throws
    {
        switch self.value.membership
        {
        case nil, membership?:
            self.value.membership = membership
        
        case let other?:
            throw Compiler.LatticeConflictError<Compiler.LatticeMembership>.init(
                existing: other)
        }
        if let origin:ScalarSymbolResolution
        {
            try self.assign(origin: origin)
        }
    }
    final
    func assign(superform:Compiler.LatticeSuperform,
        origin:ScalarSymbolResolution? = nil) throws
    {
        switch self.value.superform
        {
        case nil, superform?:
            self.value.superform = superform
        
        case let other?:
            throw Compiler.LatticeConflictError<Compiler.LatticeSuperform>.init(
                existing: other)
        }
        if let origin:ScalarSymbolResolution
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
            throw Compiler.OriginConflictError.init(existing: other)
        }
    }
}
