import SymbolColonies

public
struct Compiler
{
    let threshold:SymbolVisibility

    private
    var extensions:Extensions
    private
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
                
                case (.scalar(let scalar), included: false):
                    //  Remember this symbol’s resolution, so we can prune edges
                    //  connected to it.
                    try self.scalars.exclude(scalar: scalar)
                
                case (.scalar(let scalar), included: true):
                    try self.scalars.include(scalar: scalar, with: symbol)
                
                case (.block(let block), included: true):
                    try self.extensions.include(extended: try extensions.extendee(of: block),
                        with: symbol,
                        by: block)
                
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
                case .conformance(let conformance, origin: let origin):
                    do
                    {
                        try self.add(conformance: conformance)
                        try self.add(origin: origin)
                    }
                    catch let error
                    {
                        throw SymbolRelationshipError<SymbolRelationship.Conformance>.init(
                            underlying: error,
                            edge: conformance)
                    }
                
                case .extension:
                    //  Already handled these.
                    continue
                
                case .defaultImplementation  (_, origin: let origin):
                    try self.add(origin: origin)

                case .inheritance            (_, origin: let origin):
                    try self.add(origin: origin)

                case .membership(let membership, origin: let origin):
                    do
                    {
                        try self.add(membership: membership)
                        try self.add(origin: origin)
                    }
                    catch let error
                    {
                        throw SymbolRelationshipError<SymbolRelationship.Membership>.init(
                            underlying: error,
                            edge: membership)
                    }

                case .optionalRequirement    (_, origin: let origin):
                    try self.add(origin: origin)

                case .override               (_, origin: let origin):
                    try self.add(origin: origin)

                case .requirement            (_, origin: let origin):
                    try self.add(origin: origin)
                }
            }
        }
    }
}
extension Compiler
{
    private mutating
    func add(origin:SymbolOrigin?) throws
    {
    }
    private mutating
    func add(conformance:SymbolRelationship.Conformance) throws
    {
        guard let `protocol`:ScalarSymbolResolution = self.scalars[conformance.target]
        else
        {
            return // Protocol is hidden.
        }

        let `extension`:Extension

        switch conformance.source
        {
        case .compound:
            //  Compounds cannot conform to things.
            throw SymbolReferenceError.source
        
        case .scalar(let type):
            //  If the colonial graph was generated with '-emit-extension-symbols',
            //  we should never see an external type reference here.
            guard let type:Scalar = try self.scalars(internal: type)
            else
            {
                return // Type is hidden.
            }

            //  Generate an implicit, internal extension for this conformance,
            //  if one does not already exist.
            `extension` = self.extensions[type.resolution, where: conformance.conditions]
        
        case .block(let block):
            //  Look up the extension associated with this block name.
            `extension` = try self.extensions.named(block)

            guard conformance.conditions == `extension`.signature.conditions
            else
            {
                throw ExtensionSignatureError.init(expected: `extension`.signature)
            }
        }

        `extension`.conformances.insert(`protocol`)
    }
    private mutating
    func add(membership:SymbolRelationship.Membership) throws
    {
        switch membership.source
        {
        case .compound(let feature, self: let selftype):
            guard let feature:ScalarSymbolResolution = self.scalars[feature]
            else
            {
                return // Feature is hidden.
            }
            switch membership.target
            {
            case .compound:
                //  Nothing can be a member of a compound symbol.
                throw SymbolReferenceError.target
            
            case .scalar(let type):
                //  If the colonial graph was generated with '-emit-extension-symbols',
                //  we should never see an external type reference here.
                guard let type:Scalar = try self.scalars(internal: type)
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
                    self.extensions[type.resolution, where: nil].features.insert(feature)
                }
                else
                {
                    throw MembershipConflictError.feature(of: type.resolution)
                }
            
            case .block(let block):
                //  Look up the extension associated with this block name.
                let named:Extension = try self.extensions.named(block)
                if  named.type == selftype
                {
                    named.features.insert(feature)
                }
                else
                {
                    throw MembershipConflictError.feature(of: named.type)
                }
            }
        
        case .scalar(let member):
            //  If the colonial graph was generated with '-emit-extension-symbols',
            //  we should never see an external type reference here.
            guard let member:Scalar = try self.scalars(internal: member)
            else
            {
                return // Member is hidden.
            }

            switch membership.target
            {
            case .compound:
                //  Nothing can be a member of a compound symbol.
                throw SymbolReferenceError.target
            
            case .scalar(let type):
                //  We should never see an external type reference here either.
                if  let type:Scalar = try self.scalars(internal: type)
                {
                    try member.assign(membership: type.resolution)
                    //  Generate an implicit, internal extension for this membership,
                    //  if one does not already exist.
                    self.extensions[type.resolution, where: member.conditions].members.insert(
                        member.resolution)
                }

            case .block(let block):
                let named:Extension = try self.extensions.named(block)
                if  named.conditions == member.conditions
                {
                    try member.assign(membership: named.type)
                    named.members.insert(member.resolution)
                }
                else
                {
                    //  The member’s extension constraints don’t match the extension
                    //  object’s signature!
                    throw ExtensionSignatureError.init(expected: named.signature,
                        declared: member.conditions)
                }
            }
        
        case .block:
            //  Extension blocks cannot be members of things.
            throw SymbolReferenceError.source
        }
    }
}
