import LexicalPaths
import SymbolGraphParts
import Symbols

extension SSGC
{
    public
    struct TypeChecker
    {
        private
        let threshold:Symbol.ACL

        public private(set)
        var declarations:Declarations
        public private(set)
        var extensions:Extensions

        public
        init(root:Symbol.FileBase?, threshold:Symbol.ACL = .public)
        {
            self.threshold = threshold

            self.declarations = .init(root: root)
            self.extensions = .init()
        }
    }
}
extension SSGC.TypeChecker
{
    public mutating
    func compile(language:Phylum.Language,
        culture:Symbol.Module,
        parts:[SymbolGraphPart]) throws
    {
        for part:SymbolGraphPart in parts where part.culture != culture
        {
            throw CultureError.init(
                underlying: SSGC.UnexpectedModuleError.culture(part.culture, in: part.id),
                culture: culture)
        }

        let culture:Culture = try self.declarations.include(language: language,
            culture: culture)

        do
        {
            try self.compile(parts: parts, in: culture)
        }
        catch let error
        {
            throw CultureError.init(underlying: error, culture: culture.id)
        }
    }
    private mutating
    func compile(parts:[SymbolGraphPart], in culture:Culture) throws
    {
        /// We use this to look up protocols by name instead of symbol. This is needed in order
        /// to work around some bizarre lib/SymbolGraphGen bugs.
        var protocols:[UnqualifiedPath: Symbol.Decl] = [:]
        var others:[SSGC.DeclObject] = []
        //  Pass I. Gather scalars, extension blocks, and extension relationships.
        for part:SymbolGraphPart in parts
        {
            let namespace:SSGC.Namespace.ID = part.colony.map
            {
                self.declarations[namespace: $0]
            } ?? .index(culture.index)

            //  Map extension block names to extended type identifiers.
            let extensions:SSGC.ExtendedTypes = try .init(indexing: part)
            for vertex:SymbolGraphPart.Vertex in part.vertices
            {
                do
                {
                    switch (vertex.usr, excluded: vertex.acl < self.threshold)
                    {
                    case (.vector, excluded: true):
                        //  We do not care about vectors materialized for internal types, or
                        //  vectors materialized from internal scalars.
                        continue

                    case (.vector(let symbol), excluded: false):
                        //  Compound symbol descriptions are mostly useless. (They do not tell
                        //  us anything useful their generic/extension contexts.) But we need to
                        //  remember their names to perform codelink resolution.
                        try self.declarations.include(vector: symbol, with: vertex)

                    case (.scalar(let symbol), excluded: false):
                        let decl:SSGC.DeclObject = try self.declarations.include(scalar: symbol,
                            namespace: namespace,
                            with: vertex,
                            in: culture)

                        if  case .decl(.protocol) = vertex.phylum
                        {
                            protocols[vertex.path] = symbol
                        }
                        else
                        {
                            others.append(decl)
                        }

                    case (.scalar(let symbol), excluded: true):
                        try self.declarations.exclude(scalar: symbol)

                    case (.block(let symbol), excluded: true):
                        //  We *do* in fact care about extension blocks that only contain
                        //  internal/private members, because they might contain a conformance
                        //  to an internal protocol that inherits from a public protocol.
                        //  SymbolGraphGen probably shouldn’t be marking these extension blocks
                        //  as internal, but SymbolGraphGen doesn’t care what we think.
                        fallthrough
                        //  continue

                    case (.block(let symbol), excluded: false):
                        try self.extensions.include(block: symbol,
                            extending: try extensions.extendee(of: symbol),
                            namespace: namespace,
                            with: vertex,
                            in: culture)
                    }
                }
                catch let error
                {
                    throw SSGC.VertexError.init(underlying: error, in: vertex)
                }
            }
        }
        //  Pass II. Scan for nesting relationships.
        for part:SymbolGraphPart in parts
        {
            for relationship:Symbol.AnyRelationship in part.relationships
            {
                do
                {
                    switch relationship
                    {
                    case .extension:
                        continue // Already handled these.

                    case .requirement(let requirement):
                        try self.assign(requirement, by: culture.index)

                    case .member(let membership):
                        try self.assign(membership, by: culture.index)

                    case .conformance, .inheritance, .override, .intrinsicWitness:
                        continue // Next pass.
                    }
                }
                catch let error
                {
                    throw SSGC.EdgeError.init(underlying: error, in: relationship)
                }
            }
        }
        for part:SymbolGraphPart in parts
        {
            for relationship:Symbol.AnyRelationship in part.relationships
            {
                do
                {
                    switch relationship
                    {
                    case .extension, .requirement, .member:
                        continue // Already handled these.

                    case .conformance(let conformance):
                        try self.insert(conformance, by: culture.index)

                    case .inheritance(let relationship):
                        try self.insert(relationship)

                    case .override(let relationship):
                        try self.insert(relationship)

                    case .intrinsicWitness(let relationship):
                        try self.insert(relationship)
                    }
                }
                catch let error
                {
                    throw SSGC.EdgeError.init(underlying: error, in: relationship)
                }
            }
        }
        //  SymbolGraphGen fails to emit a `memberOf` edge if the member is a default
        //  implementation of a protocol requirement. Because the requirement might be a
        //  requirement from a different protocol than the protocol containing the default
        //  implementation, this means we need to use lexical name lookup to resolve the true
        //  parent of the default implementation.
        //
        //  Luckily for us, this lib/SymbolGraphGen bug only seems to affect default
        //  implementations that implement requirements from protocols in the current module.
        for decl:SSGC.DeclObject in others
        {
            guard decl.scopes.isEmpty,
            let parent:UnqualifiedPath = .init(decl.value.path.prefix),
            let parent:Symbol.Decl = protocols[parent]
            else
            {
                continue
            }

            let inferred:Symbol.MemberRelationship = .init(.scalar(decl.id),
                in: .scalar(parent))

            try self.assign(inferred, by: culture.index)
        }
    }
}
extension SSGC.TypeChecker
{
    private mutating
    func assign(_ relationship:Symbol.RequirementRelationship, by culture:Int) throws
    {
        /// Protocol must always be from the same module.
        if  let target:SSGC.DeclObject = try self.declarations(internal: relationship.target),
            let source:SSGC.DeclObject = try self.declarations(internal: relationship.source)
        {
            try source.assign(scope: relationship)
            try target.add(requirement: source.id)
        }
    }
    private mutating
    func assign(_ relationship:Symbol.MemberRelationship, by culture:Int) throws
    {
        switch relationship.source
        {
        case .vector(let vector):
            guard
            let feature:Symbol.Decl = self.declarations[vector.feature]
            else
            {
                return // Feature is hidden.
            }
            switch relationship.target
            {
            case .vector(let symbol):
                //  Nothing can be a member of a vector symbol.
                throw SSGC.UnexpectedSymbolError.vector(symbol)

            case .scalar(let heir):
                //  If the colonial graph was generated with '-emit-extension-symbols',
                //  we should never see an external type reference here.
                guard
                let heir:SSGC.DeclObject = try self.declarations(internal: heir)
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
                    throw SSGC.FeatureError.init(invalid: heir.id)
                }

            case .block(let block):
                //  Look up the extension associated with this block name.
                let group:SSGC.ExtensionObject = try self.extensions.named(block)
                if  group.extended.type == vector.heir
                {
                    group.add(feature: feature)
                }
                else
                {
                    throw SSGC.FeatureError.init(invalid: group.extended.type)
                }
            }

        case .scalar(let member):
            //  If the colonial graph was generated with '-emit-extension-symbols',
            //  we should never see an external type reference here.
            guard
            let member:SSGC.DeclObject = try self.declarations(internal: member)
            else
            {
                return // Member is hidden.
            }

            switch relationship.target
            {
            case .vector(let symbol):
                //  Nothing can be a member of a vector symbol.
                throw SSGC.UnexpectedSymbolError.vector(symbol)

            case .scalar(let type):
                //  We should never see an external type reference here either.
                guard
                let type:SSGC.DeclObject = try self.declarations(internal: type)
                else
                {
                    return // Type is hidden.
                }

                try member.assign(scope: relationship)

                if  case .case = member.value.phylum
                {
                    try type.add(inhabitant: member.id)
                }
                else
                {
                    //  Generate an implicit, internal extension for this membership,
                    //  if one does not already exist.
                    self.extensions(culture, type, where: member.conditions).add(
                        nested: member.id)
                }

            case .block(let block):
                let group:SSGC.ExtensionObject = try self.extensions.named(block)
                if  group.conditions == member.conditions
                {
                    try member.assign(scope: relationship)
                    group.add(nested: member.id)
                }
                else
                {
                    //  The member’s extension constraints don’t match the extension
                    //  object’s signature!
                    throw SSGC.ExtensionSignatureError.init(expected: group.signature,
                        declared: member.conditions)
                }
            }

        case .block(let symbol):
            //  Extension blocks cannot be members of things.
            throw SSGC.UnexpectedSymbolError.block(symbol)
        }
    }
}
extension SSGC.TypeChecker
{
    private mutating
    func insert(_ conformance:Symbol.ConformanceRelationship, by culture:Int) throws
    {
        guard let `protocol`:Symbol.Decl = self.declarations[conformance.target]
        else
        {
            return // Protocol is hidden.
        }

        let `extension`:SSGC.ExtensionObject

        switch conformance.source
        {
        case .vector(let symbol):
            //  Compounds cannot conform to things.
            throw SSGC.UnexpectedSymbolError.vector(symbol)

        case .scalar(let type):
            //  If the colonial graph was generated with '-emit-extension-symbols',
            //  we should never see an external type reference here.
            guard let type:SSGC.DeclObject = try self.declarations(internal: type)
            else
            {
                return // Type is hidden.
            }
            if  let origin:Symbol.Decl = conformance.origin
            {
                try type.assign(origin: origin)
            }
            if  case .protocol = type.value.phylum
            {
                //  Oddly, SymbolGraphGen uses “conformsTo” for protocol inheritance.
                //  But this conformance is not a real conformance, it is a supertype
                //  relationship!
                try type.add(superform: Symbol.InheritanceRelationship.init(
                    by: type.id,
                    of: `protocol`))
                return
            }
            //  Generate an implicit, internal extension for this conformance,
            //  if one does not already exist.
            `extension` = self.extensions(culture, type, where: conformance.conditions)

        case .block(let block):
            //  Look up the extension associated with this block name.
            `extension` = try self.extensions.named(block)

            guard `extension`.conditions == conformance.conditions
            else
            {
                throw SSGC.ExtensionSignatureError.init(expected: `extension`.signature)
            }
        }

        `extension`.add(conformance: `protocol`)
    }
    private mutating
    func insert(_ relationship:some SuperformRelationship) throws
    {
        if  case nil = self.declarations[relationship.target]
        {
            return // Superform is hidden.
        }
        /// Superform relationships are intrinsic. They must always originate from
        /// internal symbols.
        if  let subform:SSGC.DeclObject = try self.declarations(internal: relationship.source)
        {
            try subform.add(superform: relationship)
        }
        /// Having a universal witness is not intrinsic, but it is useful to know
        /// if we have one from the same package.
        if  case let relationship as Symbol.IntrinsicWitnessRelationship = relationship,
            let superform:SSGC.DeclObject = self.declarations[included: relationship.target]
        {
            superform.kinks[is: .implemented] = true
        }
    }
}
