import SymbolColonies

public
struct Compiler
{
    private
    let threshold:SymbolVisibility

    public private(set)
    var extensions:Extensions
    public private(set)
    var scalars:Scalars

    public
    init(threshold:SymbolVisibility = .public)
    {
        self.threshold = threshold

        self.extensions = .init()
        self.scalars = .init()
    }
}
extension Compiler
{
    public mutating
    func compile(colonies:some Sequence<SymbolColony>) throws
    {
        let cultures:[ModuleIdentifier: [SymbolColony]] = .init(grouping: colonies,
            by: \.culture)
        
        for (culture, colonies):(ModuleIdentifier, [SymbolColony]) in cultures
        {
            try self.compile(culture: culture, colonies: colonies)
        }
    }
    private mutating
    func compile(culture:ModuleIdentifier, colonies:[SymbolColony]) throws
    {
        for colony:SymbolColony in colonies
        {
            //  Map extension block names to extended type identifiers.
            let extensions:ExtendedTypes = try .init(indexing: colony)
            for symbol:SymbolDescription in colony.symbols
            {
                switch (symbol.usr, included: self.threshold <= symbol.visibility)
                {
                case (.compound, _):
                    //  Compound symbol descriptions are completely and utterly
                    //  useless. They do not even tell us anything useful about
                    //  their generic/extension contexts.
                    continue
                
                case (.scalar(let scalar), included: let included):
                    do
                    {
                        included ?
                        try self.scalars.include(scalar: scalar, with: symbol, in: culture) :
                        try self.scalars.exclude(scalar: scalar)
                    }
                    catch let error
                    {
                        throw SymbolDescriptionError<ScalarSymbolResolution>.init(
                            underlying: error,
                            in: scalar)
                    }
                
                case (.block(let block), included: true):
                    do
                    {
                        try self.extensions.include(
                            extended: try extensions.extendee(of: block),
                            with: symbol,
                            by: block)
                    }
                    catch let error
                    {
                        throw SymbolDescriptionError<BlockSymbolResolution>.init(
                            underlying: error,
                            in: block)
                    }
                
                case (.block, included: false):
                    //  We do not care about extension blocks that only contain
                    //  internal/private members.
                    continue
                }
            }
        }
        for colony:SymbolColony in colonies
        {
            for relationship:SymbolRelationship in colony.relationships
            {
                switch relationship
                {
                case .extension:
                    //  Already handled these.
                    continue
                
                case .conformance(let conformance):
                    try self.add(conformance)

                case .membership(let membership):
                    try self.add(membership)
                
                case .requirement(let requirement):
                    try self.add(requirement)

                case .defaultImplementation(let relationship):
                    try self.add(relationship, as: LatticeSuperform.implements(_:))

                case .inheritance(let relationship):
                    try self.add(relationship, as: LatticeSuperform.inherits(_:))

                case .override(let relationship):
                    try self.add(relationship, as: LatticeSuperform.overrides(_:))

                }
            }
        }
    }
}
extension Compiler
{

}
extension Compiler
{

}
extension Compiler
{
    private mutating
    func add(_ conformance:SymbolRelationship.Conformance) throws
    {
        do
        {
            try self.assign(relationship: conformance)
        }
        catch let error
        {
            throw SymbolRelationshipError<SymbolRelationship.Conformance>.init(
                underlying: error,
                edge: conformance)
        }
    }
    private mutating
    func add(_ membership:SymbolRelationship.Membership) throws
    {
        do
        {
            try self.assign(relationship: membership)
        }
        catch let error
        {
            throw SymbolRelationshipError<SymbolRelationship.Membership>.init(
                underlying: error,
                edge: membership)
        }
    }
    private mutating
    func add(_ requirement:SymbolRelationship.Requirement) throws
    {
        do
        {
            try self.assign(relationship: requirement)
        }
        catch let error
        {
            throw SymbolRelationshipError<SymbolRelationship.Requirement>.init(
                underlying: error,
                edge: requirement)
        }
    }
    private mutating
    func add<Relationship>(_ superform:Relationship,
        as type:(ScalarSymbolResolution) -> LatticeSuperform) throws
        where Relationship:SuperformRelationship
    {
        do
        {
            try self.assign(relationship: superform, as: type)
        }
        catch let error
        {
            throw SymbolRelationshipError<Relationship>.init(underlying: error,
                edge: superform)
        }
    }
}
extension Compiler
{
    private mutating
    func assign(relationship conformance:SymbolRelationship.Conformance) throws
    {
        guard let `protocol`:ScalarSymbolResolution = self.scalars[conformance.target]
        else
        {
            return // Protocol is hidden.
        }

        let group:ExtensionReference

        switch conformance.source
        {
        case .compound:
            //  Compounds cannot conform to things.
            throw SymbolReferenceError.source
        
        case .scalar(let type):
            //  If the colonial graph was generated with '-emit-extension-symbols',
            //  we should never see an external type reference here.
            guard let type:ScalarReference = try self.scalars(internal: type)
            else
            {
                return // Type is hidden.
            }
            if let origin:ScalarSymbolResolution = conformance.origin
            {
                try type.assign(origin: origin)
            }
            //  Generate an implicit, internal extension for this conformance,
            //  if one does not already exist.
            group = self.extensions[type.resolution, where: conformance.conditions]
        
        case .block(let block):
            //  Look up the extension associated with this block name.
            group = try self.extensions.named(block)

            guard case conformance.conditions? = group.conditions
            else
            {
                throw Extension.SignatureError.init(expected: group.signature)
            }
        }

        group.insert(conformance: `protocol`)
    }
    private mutating
    func assign(relationship:SymbolRelationship.Membership) throws
    {
        switch relationship.source
        {
        case .compound(let feature, self: let selftype):
            guard let feature:ScalarSymbolResolution = self.scalars[feature]
            else
            {
                return // Feature is hidden.
            }
            switch relationship.target
            {
            case .compound:
                //  Nothing can be a member of a compound symbol.
                throw SymbolReferenceError.target
            
            case .scalar(let type):
                //  If the colonial graph was generated with '-emit-extension-symbols',
                //  we should never see an external type reference here.
                guard let type:ScalarReference = try self.scalars(internal: type)
                else
                {
                    return // Feature is hidden.
                }
                //  If the membership target is a scalar resolution, the self type
                //  should match the target type.
                if  type.resolution == selftype
                {
                    //  We don’t know what extension the feature should go in, because
                    //  it may come from a protocol extension we do not know about. So
                    //  we put it in the “unknown” extension.
                    self.extensions[type.resolution, where: nil].insert(feature: feature)
                }
                else
                {
                    throw FeatureMembershipError.init(invalid: type.resolution)
                }
            
            case .block(let block):
                //  Look up the extension associated with this block name.
                let group:ExtensionReference = try self.extensions.named(block)
                if  group.extendee == selftype
                {
                    group.insert(feature: feature)
                }
                else
                {
                    throw FeatureMembershipError.init(invalid: group.extendee)
                }
            }
        
        case .scalar(let member):
            //  If the colonial graph was generated with '-emit-extension-symbols',
            //  we should never see an external type reference here.
            guard let member:ScalarReference = try self.scalars(internal: member)
            else
            {
                return // Member is hidden.
            }

            switch relationship.target
            {
            case .compound:
                //  Nothing can be a member of a compound symbol.
                throw SymbolReferenceError.target
            
            case .scalar(let type):
                //  We should never see an external type reference here either.
                if  let type:ScalarReference = try self.scalars(internal: type)
                {
                    try member.assign(membership: .member(of: type.resolution),
                        origin: relationship.origin)
                    //  Generate an implicit, internal extension for this membership,
                    //  if one does not already exist.
                    self.extensions[type.resolution, where: member.conditions].insert(
                        member: member.resolution)
                }

            case .block(let block):
                let group:ExtensionReference = try self.extensions.named(block)
                if case member.conditions? = group.conditions
                {
                    try member.assign(membership: .member(of: group.extendee),
                        origin: relationship.origin)
                    group.insert(member: member.resolution)
                }
                else
                {
                    //  The member’s extension constraints don’t match the extension
                    //  object’s signature!
                    throw Extension.SignatureError.init(expected: group.signature,
                        declared: member.conditions)
                }
            }
        
        case .block:
            //  Extension blocks cannot be members of things.
            throw SymbolReferenceError.source
        }
    }
    private mutating
    func assign(relationship:SymbolRelationship.Requirement) throws
    {
        /// Protocol must always be from the same module.
        guard let `protocol`:ScalarReference = try self.scalars(internal: relationship.target)
        else
        {
            return // Protocol is hidden.
        }
        if  let requirement:ScalarReference = try self.scalars(internal: relationship.source)
        {
            try requirement.assign(membership: .requirement(of: `protocol`.resolution,
                    optional: relationship.optional),
                origin: relationship.origin)
        }
    }
    private mutating
    func assign(relationship:some SuperformRelationship,
        as type:(ScalarSymbolResolution) -> LatticeSuperform) throws
    {
        guard let superform:ScalarSymbolResolution = self.scalars[relationship.target]
        else
        {
            return // Superform is hidden.
        }
        /// Superform relationships are intrinsic. They must always originate from
        /// internal symbols.
        if let subform:ScalarReference = try self.scalars(internal: relationship.source)
        {
            try subform.assign(superform: type(superform), origin: relationship.origin)
        }
    }
}
