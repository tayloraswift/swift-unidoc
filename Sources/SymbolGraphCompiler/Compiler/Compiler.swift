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
            let blocks:ExtensionBlockIndex = try .init(indexing: colony)
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
                    //  TODO: unimplemented
                    self.scalars[scalar.id] = .init(conditions: symbol.extension.conditions)
                
                case .block(let block):
                    let type:UnifiedScalarResolution = try blocks.extendee(of: block)
                    try self.extensions[type.id, where: symbol.extension.conditions].combine(
                        symbol)
                }
            }
            for relationship:SymbolRelationship in colony.relationships
            {
                try self.add(relationship: relationship, blocks: blocks)
            }
        }
    }
}
extension Compiler
{
    private mutating
    func add(relationship:SymbolRelationship, blocks:ExtensionBlockIndex) throws
    {
        switch relationship.type
        {
        case .conformer:
            try self.add(conformance: (of: relationship.source, to: relationship.target),
                where: relationship.conditions,
                blocks: blocks)
            //  Return before checking that the relationship is unconditional.
            return
        
        case .defaultImplementation:
            break
        case .extension:
            //  Already handled these.
            return
        
        case .member:
            try self.add(membership: (of: relationship.source, in: relationship.target),
                blocks: blocks)
        
        case .optionalRequirement:
            break
        case .override:
            break
        case .refinement:
            break
        case .requirement:
            break
        }

        //  TODO: ensure relationship has no conditions
    }
    private mutating
    func add(conformance:(of:UnifiedSymbolResolution, to:UnifiedSymbolResolution),
        where conditions:[GenericConstraint<SymbolIdentifier>],
        blocks:ExtensionBlockIndex) throws
    {
        switch conformance
        {
        case (of: .scalar(let type), to: .scalar(let conformance)):
            //  If the colonial graph was generated with '-emit-extension-symbols',
            //  we should never see an external type reference here.
            guard self.scalars.contains(type.id)
            else
            {
                throw ExternalRelationshipError.conformer(type, of: conformance)
            }
            //  Generate an implicit, internal extension for this conformance,
            //  if one does not already exist.
            self.extensions[type.id, where: conditions].conformances.insert(conformance.id)
        
        case (of: .block(let block), to: .scalar(let conformance)):
            //  Look up the type extended by this extension block.
            let type:UnifiedScalarResolution = try blocks.extendee(of: block)
            //  There must already exist an extension block with this
            //  relationship’s exact generic constraints.
            //
            //  The extension block should also be from this colony,
            //  but we don’t care about that right now.
            guard self.extensions.contains(type.id, where: conditions)
            else
            {
                throw ExtensionBlockSignatureError.conformance(by: block,
                    of: type,
                    to: conformance)
            }

            self.extensions[type.id, where: conditions].conformances.insert(conformance.id)
        
        case (of: let conformer, to: .scalar(let conformance)):
            //  Compounds cannot conform to things.
            throw SymbolRelationshipError.conformer(conformer, of: .scalar(conformance))
        
        case (of: let conformer, to: let conformance):
            //  Can only conform to protocols, which are scalars
            throw SymbolRelationshipError.conformance(conformance, of: conformer)
        }
    }
    private mutating
    func add(membership:(of:UnifiedSymbolResolution, in:UnifiedSymbolResolution),
        blocks:ExtensionBlockIndex) throws
    {
        switch membership
        {
        case (.compound(_, self: _), .scalar(_)):
            //  TODO: unimplemented
            break 
        
        case (.compound(_, self: _), .block(_)):
            //  TODO: unimplemented
            break
        
        case (.scalar(let member), .scalar(let type)):
            //  If the colonial graph was generated with '-emit-extension-symbols',
            //  we should never see an external type reference here.
            guard self.scalars.contains(type.id)
            else
            {
                throw ExternalRelationshipError.membership(type, of: member)
            }
            //  We should never see an external symbol reference here either.
            guard   let conditions:[GenericConstraint<SymbolIdentifier>] =
                    try self.scalars[member.id]?.assign(membership: type.id)
            else
            {
                throw ExternalRelationshipError.member(member, of: .scalar(type))
            }

            //  Generate an implicit, internal extension for this membership,
            //  if one does not already exist.
            self.extensions[type.id, where: conditions].members.insert(member.id) 
        
        case (.scalar(let member), .block(let block)):
            //  Look up the type extended by this extension block.
            let type:UnifiedScalarResolution = try blocks.extendee(of: block)

            //  Look up this member’s extension constraints.
            guard   let conditions:[GenericConstraint<SymbolIdentifier>] =
                    try self.scalars[member.id]?.assign(membership: type.id)
            else
            {
                throw ExternalRelationshipError.member(member, of: .block(block))
            }
            //  There must already exist an extension block with this
            //  member’s exact extension constraints.
            //
            //  The extension block should also be from this colony,
            //  but we don’t care about that right now.
            guard self.extensions.contains(type.id, where: conditions)
            else
            {
                throw ExtensionBlockSignatureError.membership(by: block,
                    of: member,
                    in: type)
            }

            self.extensions[type.id, where: conditions].members.insert(member.id)
        
        case (of: .block(let name), in: let membership):
            //  Extension blocks cannot be members of things.
            throw SymbolRelationshipError.member(.block(name), of: membership)
        
        case (of: let member, in: let membership):
            //  Nothing can be a member of a compound symbol.
            throw SymbolRelationshipError.membership(membership, of: member)
        }
    }
}
