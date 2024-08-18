import LexicalPaths
import LinkResolution
import Signatures
import SymbolGraphParts
import Symbols
import UCF

extension SSGC
{
    public
    struct TypeChecker
    {
        private
        let ignoreExportedInterfaces:Bool
        private
        var declarations:Declarations
        private
        var extensions:Extensions

        private
        var resolvableLinks:UCF.ResolutionTable<UCF.CausalOverload>
        private
        var resolvableModules:[Symbol.Module]

        public
        init(ignoreExportedInterfaces:Bool = true, threshold:Symbol.ACL = .public)
        {
            self.ignoreExportedInterfaces = ignoreExportedInterfaces
            self.declarations = .init(threshold: threshold)
            self.extensions = .init()

            self.resolvableLinks = [:]
            self.resolvableModules = []
        }
    }
}
extension SSGC.TypeChecker
{
    public mutating
    func add(symbols culture:SSGC.SymbolCulture) throws
    {
        var id:Symbol.Module? = nil
        for part:SSGC.SymbolDump in culture.symbols
        {
            guard
            let id:Symbol.Module
            else
            {
                id = part.culture
                continue
            }

            guard id == part.culture
            else
            {
                throw CultureError.init(
                    underlying: SSGC.UnexpectedModuleError.culture(part.culture, in: .init(
                        culture: part.culture,
                        colony: part.colony)),
                    culture: id)
            }
        }

        if  let id:Symbol.Module
        {
            try self.add(symbols: culture, from: id)
        }
    }

    private mutating
    func add(symbols culture:SSGC.SymbolCulture, from id:Symbol.Module) throws
    {
        self.resolvableModules.append(id)
        self.resolvableLinks.register(id)

        /// We use this to look up protocols by name instead of symbol. This is needed in order
        /// to work around some bizarre lib/SymbolGraphGen bugs.
        var protocolsByName:[UnqualifiedPath: Symbol.Decl] = [:]
        var children:[Int: [SSGC.DeclObject]] = [:]
        //  Pass I. Gather scalars, extension blocks, and extension relationships.
        for part:SSGC.SymbolDump in culture.symbols
        {
            //  Map extension block names to extended type identifiers.
            let extensions:SSGC.ExtendedTypes = try .init(indexing: part.extensions)
            let namespace:Symbol.Module = part.colony ?? id

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
                            culture: id)

                    case .scalar(let symbol):
                        guard
                        let decl:SSGC.DeclObject = self.declarations.include(vertex,
                            namespace: namespace,
                            culture: id)
                        else
                        {
                            //  Declaration is private or re-exported.
                            continue
                        }

                        if  case .decl(.protocol) = vertex.phylum
                        {
                            protocolsByName[vertex.path] = symbol
                        }

                        let depth:Int = decl.value.path.prefix.count
                        if  depth > 0
                        {
                            children[depth, default: []].append(decl)
                        }
                        else
                        {
                            //  We need to wait until the next pass for the nested declarations,
                            //  because we do not know if their namespaces are correct yet.
                            self.resolvableLinks[namespace, decl.value.path].append(
                                .decl(decl.value))
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
        for part:SSGC.SymbolDump in culture.symbols
        {
            for conformance:Symbol.ConformanceRelationship in part.conformances
            {
                try conformance.do { try self.insert($0, by: id) }
            }
            for inheritance:Symbol.InheritanceRelationship in part.inheritances
            {
                try inheritance.do { try self.insert($0, by: id) }
            }

            for nesting:Symbol.RequirementRelationship in part.requirements
            {
                try nesting.do { try self.assign($0) }
            }
            for nesting:Symbol.MemberRelationship in part.memberships
            {
                try nesting.do { try self.assign($0, by: id) }
            }
        }
        //  lib/SymbolGraphGen fails to emit a `memberOf` edge if the member is a default
        //  implementation of a protocol requirement. Because the requirement might be a
        //  requirement from a different protocol than the protocol containing the default
        //  implementation, this means we need to use lexical name lookup to resolve the true
        //  parent of the default implementation.
        //
        //  Luckily for us, this lib/SymbolGraphGen bug only seems to affect default
        //  implementations that implement requirements from protocols in the current module.
        for decl:SSGC.DeclObject in children.values.joined()
        {
            guard decl.scopes.isEmpty,
            let parent:UnqualifiedPath = .init(decl.value.path.prefix),
            let parent:Symbol.Decl = protocolsByName[parent]
            else
            {
                continue
            }

            let inferred:Symbol.MemberRelationship = .init(decl.id, in: .scalar(parent))

            try self.assign(inferred, by: id)
        }
        //  lib/SymbolGraphGen will place nested declarations under the wrong namespace if the
        //  outer type was re-exported from another module. This is a bug in lib/SymbolGraphGen.
        //  There is an alternative source of this information, in the `extendedModule` field of
        //  the extension context, but this field is only present for declarations that are
        //  physically written in an extension block, and also does not specify the correct
        //  namespace for types under more than one level of nesting.
        //
        //  Therefore, we need to correct the namespaces by actually inspecting the extended
        //  types of nested declarations. It is most efficient to visit the shallower
        //  declarations first, as this avoids the need to traverse the entire path hierarchy.
        for (_, decls):(Int, [SSGC.DeclObject]) in children.sorted(by: { $0.key < $1.key })
        {
            for decl:SSGC.DeclObject in decls
            {
                guard
                let scope:Symbol.Decl = decl.scopes.first,
                let scope:SSGC.DeclObject = self.declarations[visible: scope]
                else
                {
                    //  If we can’t find the parent, this symbol is probably a public member of
                    //  a private type, which is a common bug in lib/SymbolGraphGen.
                    decl.access = .private
                    continue
                }

                let namespace:Symbol.Module = scope.namespace

                decl.access = min(decl.access, scope.access)
                decl.namespace = namespace

                self.resolvableLinks[namespace, decl.value.path].append(.decl(decl.value))
            }
        }

        //  Pass II. Populate remaining relationships.
        for part:SSGC.SymbolDump in culture.symbols
        {
            for relationship:Symbol.FeatureRelationship in part.featurings
            {
                try relationship.do { try self.insert($0, by: id) }
            }
            for relationship:Symbol.IntrinsicWitnessRelationship in part.witnessings
            {
                try relationship.do { try self.insert($0, by: id) }
            }
            for relationship:Symbol.OverrideRelationship in part.overrides
            {
                try relationship.do { try self.insert($0, by: id) }
            }
        }
    }
}
extension SSGC.TypeChecker
{
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

        guard self.ignoreExportedInterfaces || member.culture == culture
        else
        {
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

            guard self.ignoreExportedInterfaces || scope.culture == culture
            else
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
                    declared: member.conditions.sorted())
            }

            try member.assign(scope: group.extendee, by: relationship)
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

        let conditions:Set<GenericConstraint<Symbol.Decl>> = .init(conformance.conditions)

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

            guard self.ignoreExportedInterfaces || type.culture == culture
            else
            {
                throw AssertionError.init(message: """
                    Found cross-module conformance relationship \
                    (from \(type.culture) in \(culture)), which should not be possible in \
                    symbol dumps generated with '-emit-extension-symbols'
                    """)
            }

            if  let origin:Symbol.Decl = conformance.origin
            {
                type.assign(origin: origin)
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
            typeExtension = self.extensions[extending: type, where: conditions]
            typeConformed = type

        case .block(let symbol):
            //  Look up the extension associated with this block name.
            typeExtension = try self.extensions[named: symbol]

            guard
            let type:SSGC.DeclObject = self.declarations[visible: typeExtension.extendee]
            else
            {
                return
            }

            typeConformed = type

            guard typeExtension.conditions == conditions
            else
            {
                throw SSGC.ExtensionSignatureError.init(expected: typeExtension.signature)
            }
        }

        typeConformed.conformances[target.id, default: []].insert(conditions)
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

        guard self.ignoreExportedInterfaces || subform.culture == culture
        else
        {
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

        let heir:SSGC.DeclObject

        switch relationship.target
        {
        case .vector(let symbol):
            //  Nothing can be a member of a vector symbol.
            throw SSGC.UnexpectedSymbolError.vector(symbol)

        case .scalar(let symbol):
            //  If the colonial graph was generated with '-emit-extension-symbols',
            //  we should never see an external type reference here.
            if  let decl:SSGC.DeclObject = self.declarations[visible: symbol]
            {
                heir = decl
            }
            else
            {
                return
            }

            guard self.ignoreExportedInterfaces || heir.culture == culture
            else
            {
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
            let conformance:Symbol.Decl = feature.scopes.first
            else
            {
                throw AssertionError.init(message: """
                    Declaration '\(feature.value.path)' has '\(feature.access)' access but \
                    has no known lexical parents
                    """)
            }

            guard feature.scopes.count == 1
            else
            {
                throw AssertionError.init(message: """
                    Declaration '\(feature.value.path)' is not eligible for feature \
                    inheritance because it has \(feature.scopes.count) lexical parents
                    """)
            }

            let conditions:Set<GenericConstraint<Symbol.Decl>>?
            do
            {
                conditions = try heir.conformances[conformance]?.simplify(
                    with: self.declarations)
            }
            catch SSGC.ConstraintReductionError.chimaeric(let reduced, from: let lists)
            {
                throw AssertionError.init(message: """
                    Failed to simplify constraints for conditional conformance \
                    (\(conformance)) of '\(heir.value.path)' because multiple conflicting \
                    conformances unify to a heterogeneous set of constraints

                    Declared constraints: \(lists)
                    Simplified constraints: \(reduced)
                    """)
            }
            catch SSGC.ConstraintReductionError.redundant(let reduced, from: let lists)
            {
                throw AssertionError.init(message: """
                    Failed to simplify constraints for conditional conformance \
                    (\(conformance)) of '\(heir.value.path)' because at least one of the \
                    constraint lists had redundancies within itself

                    Declared constraints: \(lists)
                    Simplified constraints: \(reduced)
                    """)
            }

            guard
            let conditions:Set<GenericConstraint<Symbol.Decl>>
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

            if  let extendee:SSGC.DeclObject = self.declarations[visible: group.extendee]
            {
                heir = extendee
            }
            else
            {
                return
            }

            if  group.extendee == relationship.source.heir
            {
                group.add(feature: feature.id, by: culture)
            }
            else
            {
                throw AssertionError.init(message: """
                    Found feature '\(feature.value.path)' on type '\(heir.value.path)' \
                    (\(heir.id)) from extension (\(block)) but the feature itself \
                    may only be inherited by a type with mangled name matching \
                    \(relationship.source.heir)
                    """)
            }
        }

        self.resolvableLinks[heir.namespace, heir.value.path, feature.value.path.last].append(
            .feature(feature.value, self: heir.id))
    }
}
extension SSGC.TypeChecker
{
    public __consuming
    func load(in culture:Symbol.Module) throws -> SSGC.ModuleIndex
    {
        let extensions:[SSGC.Extension] = try self.extensions.load(culture: culture,
            with: self.declarations)

        let features:[Symbol.Decl: SSGC.ModuleIndex.Feature] = try extensions.reduce(into: [:])
        {
            for feature:Symbol.Decl in $1.features
            {
                try
                {
                    $0 = try $0 ?? .init(from: try self.declarations[feature].value)
                } (&$0[feature])
            }
        }

        return .init(id: culture,
            resolvableModules: self.resolvableModules,
            resolvableLinks: self.resolvableLinks,
            declarations: self.declarations.load(culture: culture),
            extensions: extensions,
            features: features)
    }
}
