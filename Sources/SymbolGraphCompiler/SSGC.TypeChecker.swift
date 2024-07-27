import LexicalPaths
import Signatures
import SymbolGraphParts
import Symbols

extension SSGC
{
    public
    struct TypeChecker
    {
        private
        let ignoreExportedInterfaces:Bool
        private
        var declarations:DeclarationTable
        private
        var extensions:ExtensionTable

        public
        init(ignoreExportedInterfaces:Bool = true, threshold:Symbol.ACL = .public)
        {
            self.ignoreExportedInterfaces = ignoreExportedInterfaces
            self.declarations = .init(threshold: threshold)
            self.extensions = .init()
        }
    }
}
extension SSGC.TypeChecker
{
    public mutating
    func add(symbols dump:SSGC.SymbolDump) throws
    {
        var culture:Symbol.Module? = nil
        for part:SSGC.SymbolDump.Part in dump.parts
        {
            guard
            let culture:Symbol.Module
            else
            {
                culture = part.culture
                continue
            }

            guard culture == part.culture
            else
            {
                throw CultureError.init(
                    underlying: SSGC.UnexpectedModuleError.culture(part.culture, in: .init(
                        culture: part.culture,
                        colony: part.colony)),
                    culture: culture)
            }
        }

        if  let culture:Symbol.Module
        {
            try self.add(symbols: dump, as: culture)
        }
    }

    private mutating
    func add(symbols dump:SSGC.SymbolDump, as culture:Symbol.Module) throws
    {
        /// We use this to look up protocols by name instead of symbol. This is needed in order
        /// to work around some bizarre lib/SymbolGraphGen bugs.
        var protocolsByName:[UnqualifiedPath: Symbol.Decl] = [:]
        var children:[SSGC.DeclObject] = []
        //  Pass I. Gather scalars, extension blocks, and extension relationships.
        for part:SSGC.SymbolDump.Part in dump.parts
        {
            //  Map extension block names to extended type identifiers.
            let extensions:SSGC.ExtendedTypes = try .init(indexing: part.extensions)
            let namespace:Symbol.Module = part.colony ?? culture

            for vertex:SymbolGraphPart.Vertex in part.vertices
            {
                do
                {
                    switch vertex.usr
                    {
                    case .block(let symbol):
                    //  We *do* in fact care about extension blocks that only contain
                    //  internal/private members, because they might contain a conformance
                    //  to an internal protocol that inherits from a public protocol.
                    //  SymbolGraphGen probably shouldn’t be marking these extension blocks
                    //  as internal, but SymbolGraphGen doesn’t care what we think.
                        self.extensions.include(vertex,
                            extending: try extensions.extendee(of: symbol),
                            namespace: namespace,
                            culture: culture)

                    case .scalar(let symbol):
                        let decl:SSGC.DeclObject = self.declarations.include(vertex,
                            namespace: namespace,
                            culture: culture)

                        if  case .decl(.protocol) = vertex.phylum
                        {
                            protocolsByName[vertex.path] = symbol
                        }
                        else if !decl.value.path.prefix.isEmpty
                        {
                            children.append(decl)
                        }

                    case .vector:
                        continue
                    }
                }
                catch let error
                {
                    throw SSGC.VertexError.init(underlying: error, in: vertex)
                }
            }
        }

        //  Pass II. Populate protocol conformance tables and nesting relationships.
        for part:SSGC.SymbolDump.Part in dump.parts
        {
            for conformance:Symbol.ConformanceRelationship in part.conformances
            {
                try conformance.do { try self.insert($0, by: culture) }
            }
            for inheritance:Symbol.InheritanceRelationship in part.inheritances
            {
                try inheritance.do { try self.insert($0, by: culture) }
            }

            for nesting:Symbol.RequirementRelationship in part.requirements
            {
                try nesting.do { try self.assign($0) }
            }
            for nesting:Symbol.MemberRelationship in part.memberships
            {
                try nesting.do { try self.assign($0, by: culture) }
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
        for decl:SSGC.DeclObject in children
        {
            guard decl.scopes.isEmpty,
            let parent:UnqualifiedPath = .init(decl.value.path.prefix),
            let parent:Symbol.Decl = protocolsByName[parent]
            else
            {
                continue
            }

            let inferred:Symbol.MemberRelationship = .init(decl.id, in: .scalar(parent))

            try self.assign(inferred, by: culture)
        }

        //  Pass II. Populate remaining relationships.
        for part:SSGC.SymbolDump.Part in dump.parts
        {
            for relationship:Symbol.FeatureRelationship in part.featurings
            {
                try relationship.do { try self.insert($0, by: culture) }
            }
            for relationship:Symbol.IntrinsicWitnessRelationship in part.witnessings
            {
                try relationship.do { try self.insert($0, by: culture) }
            }
            for relationship:Symbol.OverrideRelationship in part.overrides
            {
                try relationship.do { try self.insert($0, by: culture) }
            }
        }
    }
}
extension SSGC.TypeChecker{
    /// Note that this is culture-agnostic because requirement relationships never cross
    /// modules.
    private mutating
    func assign(_ relationship:Symbol.RequirementRelationship) throws
    {
        let target:SSGC.DeclObject = try self.declarations[relationship.target]
        let source:SSGC.DeclObject = try self.declarations[relationship.source]
        try source.assign(scope: target.id, by: relationship)
        try target.add(requirement: source.id)
    }

    private mutating
    func assign(_ relationship:Symbol.MemberRelationship, by culture:Symbol.Module) throws
    {
        guard
        let member:SSGC.DeclObject = self.declarations[visible: relationship.source]
        else
        {
            return
        }

        if  member.culture != culture
        {
            if  self.ignoreExportedInterfaces
            {
                return
            }

            throw AssertionError.init(message: """
                Found cross-module member relationship \
                (from \(member.culture) in \(culture)), which should not be possible in \
                symbol dumps generated with '-emit-extension-symbols'
                """)
        }

        switch relationship.target
        {
        case .vector(let symbol):
            //  Nothing can be a member of a vector symbol.
            throw SSGC.UnexpectedSymbolError.vector(symbol)

        case .scalar(let scope):
            //  We should never see an external type reference here either.
            guard
            let scope:SSGC.DeclObject = self.declarations[visible: scope]
            else
            {
                return
            }

            if  scope.culture != culture
            {
                throw AssertionError.init(message: """
                    Found cross-module member relationship \
                    (to \(scope.culture) in \(culture)), which should not be possible in \
                    symbol dumps generated with '-emit-extension-symbols'
                    """)
            }

            //  Enum cases are considered intrinsic members of their parent enum.
            if  case .case = member.value.phylum
            {
                try scope.add(inhabitant: member.id)
            }
            else
            {
                //  Generate an implicit, internal extension for this membership,
                //  if one does not already exist.
                self.extensions[extending: scope, where: member.conditions].add(
                    nested: member.id,
                    by: culture)
            }

            try member.assign(scope: scope.id, by: relationship)

        case .block(let block):
            let group:SSGC.ExtensionObject = try self.extensions[named: block]
            if  group.conditions == member.conditions
            {
                group.add(nested: member.id, by: culture)
            }
            else
            {
                //  The member’s extension constraints don’t match the extension
                //  object’s signature!
                throw SSGC.ExtensionSignatureError.init(expected: group.signature,
                    declared: member.conditions)
            }

            try member.assign(scope: group.extended.type, by: relationship)
        }
    }
}
extension SSGC.TypeChecker
{
    private mutating
    func insert(_ conformance:Symbol.ConformanceRelationship, by culture:Symbol.Module) throws
    {
        guard
        let target:SSGC.DeclObject = self.declarations[visible: conformance.target]
        else
        {
            return
        }

        let typeExtension:SSGC.ExtensionObject
        let typeConformed:SSGC.DeclObject

        switch conformance.source
        {
        case .vector(let symbol):
            //  Compounds cannot conform to things.
            throw SSGC.UnexpectedSymbolError.vector(symbol)

        case .scalar(let symbol):
            guard
            let type:SSGC.DeclObject = self.declarations[visible: symbol]
            else
            {
                return
            }

            if  type.culture != culture
            {
                if  self.ignoreExportedInterfaces
                {
                    return
                }

                throw AssertionError.init(message: """
                    Found cross-module conformance relationship \
                    (from \(type.culture) in \(culture)), which should not be possible in \
                    symbol dumps generated with '-emit-extension-symbols'
                    """)
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
                    of: target.id))
                return
            }
            //  Generate an implicit, internal extension for this conformance,
            //  if one does not already exist.
            typeExtension = self.extensions[extending: type, where: conformance.conditions]
            typeConformed = type

        case .block(let symbol):
            //  Look up the extension associated with this block name.
            typeExtension = try self.extensions[named: symbol]

            guard
            let type:SSGC.DeclObject = self.declarations[visible: typeExtension.extended.type]
            else
            {
                return
            }

            typeConformed = type

            guard typeExtension.conditions == conformance.conditions
            else
            {
                throw SSGC.ExtensionSignatureError.init(expected: typeExtension.signature)
            }
        }

        typeConformed.conformances[target.id] = conformance.conditions
        typeExtension.add(conformance: target.id, by: culture)
    }

    private mutating
    func insert(_ relationship:some SuperformRelationship, by culture:Symbol.Module) throws
    {
        guard
        let superform:SSGC.DeclObject = self.declarations[visible: relationship.target],
        let subform:SSGC.DeclObject = self.declarations[visible: relationship.source]
        else
        {
            return
        }

        if  subform.culture != culture
        {
            if  self.ignoreExportedInterfaces
            {
                return
            }

            throw AssertionError.init(message: """
                Found retroactive superform relationship (from \(subform.culture) in \(culture))
                """)
        }

        try subform.add(superform: relationship)

        /// Having a universal witness is not intrinsic, but it is useful to know
        /// if we have one from the same package.
        if  relationship is Symbol.IntrinsicWitnessRelationship
        {
            superform.kinks[is: .implemented] = true
        }
    }

    private mutating
    func insert(_ relationship:Symbol.FeatureRelationship, by culture:Symbol.Module) throws
    {
        guard
        let feature:SSGC.DeclObject = self.declarations[visible: relationship.source.feature]
        else
        {
            return
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
            let heir:SSGC.DeclObject = self.declarations[visible: heir]
            else
            {
                return
            }

            guard heir.culture == culture
            else
            {
                if  self.ignoreExportedInterfaces
                {
                    return
                }

                throw AssertionError.init(message: """
                    Found direct cross-module feature inheritance relationship in culture \
                    '\(culture)' adding feature '\(feature.value.path)' to type \
                    '\(heir.value.path)' from '\(heir.culture)', which should not be \
                    possible in symbol dumps generated with '-emit-extension-symbols'
                    """)
            }
            guard heir.id == relationship.source.heir
            else
            {
                throw AssertionError.init(message: """
                    Found feature '\(feature.value.path)' on type '\(heir.value.path)' \
                    (\(heir.id)) but the feature itself may only be inherited by a type with \
                    mangled name matching \(relationship.source.heir)
                    """)
            }
            guard
            let conformance:Symbol.Decl = feature.scopes.first, feature.scopes.count == 1
            else
            {
                throw AssertionError.init(message: """
                    Declaration '\(feature.value.path)' is not eligible for feature \
                    inheritance because it has \(feature.scopes.count) lexical parents
                    """)
            }

            guard
            let conditions:[GenericConstraint<Symbol.Decl>] = heir.conformances[conformance]
            else
            {
                throw AssertionError.init(message: """
                    Declaration '\(heir.value.path)' cannot inherit feature \
                    '\(feature.value.path)' because it itself does not conform to \
                    '\(feature.value.path.prefix.joined(separator: "."))' (\(conformance))
                    """)
            }

            self.extensions[extending: heir, where: conditions].add(
                feature: feature.id,
                by: culture)

        case .block(let block):
            //  Look up the extension associated with this block name.
            let group:SSGC.ExtensionObject = try self.extensions[named: block]
            if  group.extended.type == relationship.source.heir
            {
                group.add(feature: feature.id, by: culture)
            }
            else
            {
                throw AssertionError.init(message: """
                    Found feature '\(feature.value.path)' on type '\(group.path)' \
                    (\(group.extended.type)) from extension (\(block)) but the feature itself \
                    may only be inherited by a type with mangled name matching \
                    \(relationship.source.heir)
                    """)
            }
        }
    }
}
extension SSGC.TypeChecker
{
    public
    func declarations(in culture:Symbol.Module, language:Phylum.Language) -> SSGC.Declarations
    {
        .init(namespaces: self.declarations.load(culture: culture),
            language: language,
            culture: culture)
    }

    public
    func extensions(in culture:Symbol.Module) throws -> SSGC.Extensions
    {
        let extensions:[SSGC.Extension] = self.extensions.load(culture: culture)

        let features:[Symbol.Decl: SSGC.Extensions.Feature] = try extensions.reduce(into: [:])
        {
            for feature:Symbol.Decl in $1.features
            {
                try
                {
                    $0 = try $0 ?? .init(from: try self.declarations[feature].value)
                } (&$0[feature])
            }
        }

        return .init(compiled: extensions, features: features, culture: culture)
    }
}
