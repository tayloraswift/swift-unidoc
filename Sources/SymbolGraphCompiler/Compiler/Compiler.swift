import SymbolColonies

public
struct Compiler
{
    private
    var extensions:Extensions
    private
    var scalars:Scalars

    public
    init()
    {
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
            //  Pass I:
            //  Map extension block names to extended type identifiers.
            let types:ExtendedTypes = try .init(indexing: colony)
            //  Pass II: 
            //  Collect explicit (external) extension blocks.
            for symbol:SymbolDescription in colony.symbols
            {
                switch symbol.usr
                {
                case .compound:
                    //  Compound symbol descriptions are completely and utterly
                    //  useless. They do not even tell us anything useful about
                    //  their generic/extension contexts.
                    continue
                
                case .scalar(let scalar):
                    self.scalars[scalar] = .init(conditions: symbol.extension.conditions)
                
                case .block(let block):
                    try self.extensions.extend(type: try types.extendee(of: block),
                        with: symbol,
                        as: block)
                }
            }
            for relationship:SymbolRelationship in colony.relationships
            {
                switch relationship
                {
                case .conformance(let conformance, origin: let origin):
                    try self.add(conformance: conformance)
                    try self.add(origin: origin)
                
                case .extension:
                    //  Already handled these.
                    continue
                
                case .defaultImplementation  (_, origin: let origin):
                    try self.add(origin: origin)

                case .inheritance            (_, origin: let origin):
                    try self.add(origin: origin)

                case .membership(let membership, origin: let origin):
                    try self.add(membership: membership)
                    try self.add(origin: origin)

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
        switch conformance.source
        {
        case .compound:
            //  Compounds cannot conform to things.
            throw SymbolRelationshipError.conformer(conformance)
        
        case .scalar(let type):
            //  If the colonial graph was generated with '-emit-extension-symbols',
            //  we should never see an external type reference here.
            if  self.scalars.contains(type)
            {
                //  Generate an implicit, internal extension for this conformance,
                //  if one does not already exist.
                self.extensions[type, where: conformance.conditions].conformances.insert(
                    conformance.target)
            }
            else
            {
                throw ExternalRelationshipError.conformer(type, of: conformance.target)
            }
        
        case .block(let block):
            //  Look up the extension associated with this block name.
            let named:Extension = try self.extensions.named(block)
            if  named.conditions == conformance.conditions
            {
                named.conformances.insert(conformance.target)
            }
            else
            {
                throw ExtensionSignatureError.conformance(conformance,
                    expected: named.signature)
            }
        }
    }
    private mutating
    func add(membership:SymbolRelationship.Membership) throws
    {
        switch (membership.source, membership.target)
        {
        case (.compound(let feature, self: let selftype), .scalar(let type)):
            //  If the membership target is a scalar resolution, the self type
            //  should match the target type.
            guard selftype == type
            else
            {
                throw MembershipConflictError.feature(of: type, self: selftype)
            }
            //  If the colonial graph was generated with '-emit-extension-symbols',
            //  we should never see an external type reference here.
            guard self.scalars.contains(type)
            else
            {
                throw ExternalRelationshipError.membership(type, of: feature)
            }
            //  We don’t know what extension the feature should go in, because
            //  it may come from a protocol extension we do not know about. So
            //  we put it in the “unknown” extension.
            self.extensions[type, where: nil].features.insert(feature)
        
        case (.compound(let feature, self: let selftype), .block(let block)):
            //  Look up the extension associated with this block name.
            let named:Extension = try self.extensions.named(block)
            if  named.type == selftype
            {
                named.features.insert(feature)
            }
            else
            {
                throw MembershipConflictError.feature(of: named.type, self: selftype)
            }
        
        case (.scalar(let member), .scalar(let type)):
            //  If the colonial graph was generated with '-emit-extension-symbols',
            //  we should never see an external type reference here.
            guard self.scalars.contains(type)
            else
            {
                throw ExternalRelationshipError.membership(type, of: member)
            }
            //  We should never see an external symbol reference here either.
            if  let conditions:[GenericConstraint<ScalarSymbolResolution>] =
                    try self.scalars[member]?.assign(membership: type)
            {
                //  Generate an implicit, internal extension for this membership,
                //  if one does not already exist.
                self.extensions[type, where: conditions].members.insert(member) 
            }
            else
            {
                throw ExternalRelationshipError.member(member, of: type)
            }
        
        case (.scalar(let member), .block(let block)):
            //  Look up the extension associated with this block name.
            let named:Extension = try self.extensions.named(block)

            //  Look up this member’s extension constraints.
            switch try self.scalars[member]?.assign(membership: named.type)
            {
            case named.conditions?:
                named.members.insert(member)
            
            case let conditions?:
                //  The member’s extension constraints don’t match the extension
                //  object’s signature!
                throw ExtensionSignatureError.membership(membership,
                    expected: named.signature,
                    declared: conditions)

            case nil:
                throw ExternalRelationshipError.member(member, of: named.type)
            }
        
        case (.block, _):
            //  Extension blocks cannot be members of things.
            throw SymbolRelationshipError.member(membership)
        
        case (_, .compound):
            //  Nothing can be a member of a compound symbol.
            throw SymbolRelationshipError.membership(membership)
        }
    }
}
