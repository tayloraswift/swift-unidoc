import SymbolColonies

public
struct Compiler
{
    private
    var extensions:Extensions

    public
    init()
    {
        self.extensions = .init()
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
                
                case .scalar(_):
                    //  TODO: unimplemented
                    continue
                
                case .block(let block):
                    let type:SymbolIdentifier = try blocks.extendee(of: block)
                    try self.extensions[type, where: symbol.extension.conditions].combine(symbol)
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
            guard case .scalar(let conformance) = relationship.target
            else
            {
                //  Can only conform to protocols, which are scalars
                throw SymbolRelationshipError.target(of: relationship)
            }
            switch relationship.source
            {
            case .compound:
                //  Compounds cannot conform to things.
                throw SymbolRelationshipError.source(of: relationship)
            
            case .scalar(let type):
                //  Generate an implicit, internal extension for this conformance,
                //  if one does not already exist.
                self.extensions[type.id, where: relationship.conditions].conformances.insert(
                    conformance.id)
            
            case .block(let block):
                //  Look up the type extended by this extension block.
                let type:SymbolIdentifier = try blocks.extendee(of: block)
                //  There must already exist an extension block with this
                //  relationship’s exact generic constraints.
                //
                //  The extension block should also be from this colony,
                //  but we don’t care about that right now.
                guard self.extensions.contains(type, where: relationship.conditions)
                else
                {
                    throw ExtensionBlockConformanceError.init(conformance: conformance,
                        type: .init(type),
                        usr: .block(block))
                }

                self.extensions[type, where: relationship.conditions].conformances.insert(
                    conformance.id)
            }
        
        case .defaultImplementation:
            break
        case .extension:
            break
        case .member:
            break
        case .optionalRequirement:
            break
        case .override:
            break
        case .refinement:
            break
        case .requirement:
            break
        }
    }
}
