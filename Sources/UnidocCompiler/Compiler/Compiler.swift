import SymbolGraphParts
import Symbols
import Repositories

public
struct Compiler
{
    private
    let threshold:SymbolDescription.Visibility
    private
    let root:Repository.Root?

    public private(set)
    var extensions:Extensions
    public private(set)
    var scalars:Scalars

    public
    init(root:Repository.Root?, threshold:SymbolDescription.Visibility = .public)
    {
        self.threshold = threshold
        self.root = root

        self.extensions = .init()
        self.scalars = .init()
    }
}
extension Compiler
{
    public mutating
    func compile(parts:some Sequence<SymbolGraphPart>) throws
    {
        let cultures:[ModuleIdentifier: [SymbolGraphPart]] = .init(grouping: parts,
            by: \.culture)

        for (culture, parts):(ModuleIdentifier, [SymbolGraphPart]) in cultures
        {
            try self.compile(culture: culture, parts: parts)
        }
    }
    private mutating
    func compile(culture:ModuleIdentifier, parts:[SymbolGraphPart]) throws
    {
        let context:SourceContext = .init(culture: culture, root: self.root)

        //  Pass I. Gather scalars, extension blocks, and extension relationships.
        for part:SymbolGraphPart in parts
        {
            //  Map extension block names to extended type identifiers.
            let extensions:ExtendedTypes = try .init(indexing: part)
            for symbol:SymbolDescription in part.symbols
            {
                do
                {
                    switch (symbol.usr, included: self.threshold <= symbol.visibility)
                    {
                    case (.vector, included: false):
                        //  We do not care about vectors materialized for internal
                        //  types, or vectors materialized from internal scalars.
                        continue

                    case (.vector(let vector), included: true):
                        //  Compound symbol descriptions are mostly useless. (They do
                        //  not tell us anything useful their generic/extension contexts.)
                        //  But we need to remember their names to perform codelink
                        //  resolution.
                        try self.scalars.include(vector: vector, with: symbol)

                    case (.scalar(let scalar), included: let included):
                        included ?
                        try self.scalars.include(scalar: scalar, with: symbol, in: context) :
                        try self.scalars.exclude(scalar: scalar)

                    case (.block(let block), included: true):
                        try self.extensions.include(block: block,
                            extending: try extensions.extendee(of: block),
                            with: symbol,
                            in: context)

                    case (.block, included: false):
                        //  We do not care about extension blocks that only contain
                        //  internal/private members.
                        continue
                    }
                }
                catch let error
                {
                    throw VertexError.init(underlying: error, in: symbol)
                }
            }
        }
        //  Pass II. Scan for nesting relationships.
        for part:SymbolGraphPart in parts
        {
            for relationship:SymbolRelationship in part.relationships
            {
                do
                {
                    switch relationship
                    {
                    case .extension:
                        continue // Already handled these.

                    case .requirement(let requirement):
                        try self.assign(requirement)

                    case .membership(let membership):
                        try self.assign(membership)

                    case .conformance, .defaultImplementation, .inheritance, .override:
                        continue // Next pass.
                    }
                }
                catch let error
                {
                    throw EdgeError.init(underlying: error, in: relationship)
                }
            }
        }
        for part:SymbolGraphPart in parts
        {
            for relationship:SymbolRelationship in part.relationships
            {
                do
                {
                    switch relationship
                    {
                    case .extension, .requirement, .membership:
                        continue // Already handled these.

                    case .conformance(let conformance):
                        try self.insert(conformance)

                    case .defaultImplementation(let relationship):
                        try self.insert(relationship)

                    case .inheritance(let relationship):
                        try self.insert(relationship)

                    case .override(let relationship):
                        try self.insert(relationship)
                    }
                }
                catch let error
                {
                    throw EdgeError.init(underlying: error, in: relationship)
                }
            }
        }
    }
}
extension Compiler
{
    private mutating
    func assign(_ relationship:SymbolRelationship.Requirement) throws
    {
        /// Protocol must always be from the same module.
        guard let `protocol`:ScalarReference = try self.scalars(internal: relationship.target)
        else
        {
            return // Protocol is hidden.
        }
        if  let requirement:ScalarReference = try self.scalars(internal: relationship.source)
        {
            try requirement.assign(nesting: relationship)

            //  Generate an implicit, internal extension for this requirement,
            //  if one does not already exist.
            self.extensions(`protocol`, where: []).add(nested: requirement.id)
        }
    }
    private mutating
    func assign(_ relationship:SymbolRelationship.Membership) throws
    {
        switch relationship.source
        {
        case .vector(let vector):
            guard let feature:ScalarSymbol = self.scalars[vector.feature]
            else
            {
                return // Feature is hidden.
            }
            switch relationship.target
            {
            case .vector(let symbol):
                //  Nothing can be a member of a vector symbol.
                throw UnexpectedSymbolError.vector(symbol)

            case .scalar(let heir):
                //  If the colonial graph was generated with '-emit-extension-symbols',
                //  we should never see an external type reference here.
                guard let heir:ScalarReference = try self.scalars(internal: heir)
                else
                {
                    return // Feature is hidden.
                }
                //  If the membership target is a scalar resolution, the self type
                //  should match the target type.
                if  heir.id == vector.heir
                {
                    //  We don’t know what extension the feature should go in, because
                    //  we would need to know the protocol it is a member of, and look
                    //  up the generic constraints of the inheriting type’s conformance
                    //  to that protocol. We can do the second thing, but not the first.
                    heir.add(feature: feature, where: nil)
                }
                else
                {
                    throw FeatureError.init(invalid: heir.id)
                }

            case .block(let block):
                //  Look up the extension associated with this block name.
                let group:ExtensionReference = try self.extensions.named(block)
                if  group.extendee == vector.heir
                {
                    group.add(feature: feature)
                }
                else
                {
                    throw FeatureError.init(invalid: group.extendee)
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
            case .vector(let symbol):
                //  Nothing can be a member of a vector symbol.
                throw UnexpectedSymbolError.vector(symbol)

            case .scalar(let type):
                //  We should never see an external type reference here either.
                if  let type:ScalarReference = try self.scalars(internal: type)
                {
                    try member.assign(nesting: relationship)
                    //  Generate an implicit, internal extension for this membership,
                    //  if one does not already exist.
                    self.extensions(type, where: member.conditions).add(nested: member.id)
                }

            case .block(let block):
                let group:ExtensionReference = try self.extensions.named(block)
                if  group.conditions == member.conditions
                {
                    try member.assign(nesting: relationship)
                    group.add(nested: member.id)
                }
                else
                {
                    //  The member’s extension constraints don’t match the extension
                    //  object’s signature!
                    throw Extension.SignatureError.init(expected: group.signature,
                        declared: member.conditions)
                }
            }

        case .block(let symbol):
            //  Extension blocks cannot be members of things.
            throw UnexpectedSymbolError.block(symbol)
        }
    }
}
extension Compiler
{
    private mutating
    func insert(_ conformance:SymbolRelationship.Conformance) throws
    {
        guard let `protocol`:ScalarSymbol = self.scalars[conformance.target]
        else
        {
            return // Protocol is hidden.
        }

        let group:ExtensionReference

        switch conformance.source
        {
        case .vector(let symbol):
            //  Compounds cannot conform to things.
            throw UnexpectedSymbolError.vector(symbol)

        case .scalar(let type):
            //  If the colonial graph was generated with '-emit-extension-symbols',
            //  we should never see an external type reference here.
            guard let type:ScalarReference = try self.scalars(internal: type)
            else
            {
                return // Type is hidden.
            }
            if let origin:ScalarSymbol = conformance.origin
            {
                try type.assign(origin: origin)
            }
            //  Generate an implicit, internal extension for this conformance,
            //  if one does not already exist.
            group = self.extensions(type, where: conformance.conditions)

        case .block(let block):
            //  Look up the extension associated with this block name.
            group = try self.extensions.named(block)

            guard group.conditions == conformance.conditions
            else
            {
                throw Extension.SignatureError.init(expected: group.signature)
            }
        }

        group.add(conformance: `protocol`)
    }
    private mutating
    func insert(_ relationship:some SuperformRelationship) throws
    {
        if case nil = self.scalars[relationship.target]
        {
            return // Superform is hidden.
        }
        /// Superform relationships are intrinsic. They must always originate from
        /// internal symbols.
        if  let subform:ScalarReference = try self.scalars(internal: relationship.source)
        {
            try subform.add(superform: relationship)
        }
    }
}
