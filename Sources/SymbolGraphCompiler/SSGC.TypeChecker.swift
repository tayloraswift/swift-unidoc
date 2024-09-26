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
        var declarations:Declarations
        private
        var extensions:Extensions

        private
        var allModules:[Symbol.Module]

        public
        init(threshold:Symbol.ACL = .public)
        {
            self.declarations = .init(threshold: threshold)
            self.extensions = .init()
            self.allModules = []
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
        self.allModules.append(id)

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

                            //  Note that in this branch, we do not yet know if the namespaces
                            //  are correct yet.
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
        let typesConformed:Set<SSGC.DeclObject> = try culture.symbols.reduce(into: [])
        {
            for conformance:Symbol.ConformanceRelationship in $1.conformances
            {
                let typeConformed:SSGC.DeclObject? = try conformance.do
                {
                    try self.collectConformance($0, by: id)
                }
                if  let typeConformed:SSGC.DeclObject
                {
                    $0.insert(typeConformed)
                }
            }

            for inheritance:Symbol.InheritanceRelationship in $1.inheritances
            {
                try inheritance.do { try self.insert($0, by: id) }
            }

            for nesting:Symbol.RequirementRelationship in $1.requirements
            {
                try nesting.do { try self.assign($0) }
            }
            for nesting:Symbol.MemberRelationship in $1.memberships
            {
                try nesting.do { try self.assign($0, by: id) }
            }
        }

        //  This uses information about the superforms of a type to simplify the constraints,
        //  which is why it is done after the inheritance relationships are recorded.
        for type:SSGC.DeclObject in typesConformed
        {
            try self.computeConformances(of: type, by: id)
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
                decl.namespaces.insert(namespace)
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

        switch relationship.target
        {
        case .vector(let symbol):
            //  Nothing can be a member of a vector symbol.
            throw SSGC.UnexpectedSymbolError.vector(symbol)

        case .scalar(let scope):
            guard
            let scope:SSGC.DeclObject = self.declarations[visible: scope]
            else
            {
                return
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
                throw SSGC.ExtensionSignatureError.member(
                    expected: group.signature,
                    declared: member.conditions.sorted())
            }

            try member.assign(scope: group.extendee, by: relationship)
        }
    }
}
extension SSGC.TypeChecker
{
    private mutating
    func collectConformance(_ conformance:Symbol.ConformanceRelationship,
        by culture:Symbol.Module) throws -> SSGC.DeclObject?
    {
        guard
        let target:SSGC.DeclObject = self.declarations[visible: conformance.target]
        else
        {
            return nil
        }

        let conditions:Set<GenericConstraint<Symbol.Decl>> = .init(conformance.conditions)
        let conformer:SSGC.DeclObject

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
                return nil
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
                return nil
            }

            conformer = type

        case .block(let symbol):
            //  Look up the extension associated with this block name.
            let named:SSGC.ExtensionObject = try self.extensions[named: symbol]

            guard
            let type:SSGC.DeclObject = self.declarations[visible: named.extendee]
            else
            {
                return nil
            }

            conformer = type

            //  This assertion disabled due to Apple Swift bug:
            //  https://github.com/swiftlang/swift/issues/76559
            guard named.conditions == conditions || { true }()
            else
            {
                throw SSGC.ExtensionSignatureError.conformance(
                    expected: named.signature,
                    declared: conformance.conditions)
            }
        }

        conformer.conformanceStatements[target.id, default: []].insert(conditions)
        return conformer
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

        try subform.add(superform: relationship)

        /// Having a universal witness is not intrinsic, but it is useful to know
        /// if we have one from the same package.
        if  relationship is Symbol.IntrinsicWitnessRelationship
        {
            superform.kinks[is: .implemented] = true
        }
    }
}
extension SSGC.TypeChecker
{
    private
    func computeConformance(where conditions:Set<Set<GenericConstraint<Symbol.Decl>>>,
        to target:Symbol.Decl,
        of type:SSGC.DeclObject) throws -> Set<GenericConstraint<Symbol.Decl>>
    {
        do
        {
            return try conditions.simplified(with: self.declarations)
        }
        catch SSGC.ConstraintReductionError.chimaeric(let reduced, from: let lists)
        {
            throw AssertionError.init(message: """
                Failed to simplify constraints for conditional conformance \
                (\(target)) of '\(type.value.path)' because multiple conflicting \
                conformances unify to a heterogeneous set of constraints

                Declared constraints: \(lists.map(\.humanReadable))
                Simplified constraints: \(reduced.humanReadable)
                """)
        }
        catch SSGC.ConstraintReductionError.redundant(let reduced, from: let lists)
        {
            throw AssertionError.init(message: """
                Failed to simplify constraints for conditional conformance \
                (\(target)) of '\(type.value.path)' due to multiple conflicting conditional
                conformances parsed from Swift compiler output

                Declared constraints: \(lists.map(\.humanReadable))
                Simplified constraints: \(reduced.humanReadable)
                """)
        }
    }
    private mutating
    func computeConformances(of type:SSGC.DeclObject, by culture:Symbol.Module) throws
    {
        for (target, overlapping):(Symbol.Decl, Set<Set<GenericConstraint<Symbol.Decl>>>)
            in type.conformanceStatements
        {
            try
            {
                //  A Swift type may only conform to a protocol once, even with different
                //  conditional constraints.
                //
                //  Exiting here not only prevents us from doing unnecessary simplification
                //  work, but also prevents us from accidentally capturing another module’s
                //  conformances as our own.
                //
                //  For example: `Foundation` conforms `Array` to `Sequence` where `Element`
                //  is `UInt8`. Because the constraints are different (and tighter) than the
                //  original conformance, our regular de-duplication logic would not flag this
                //  as a duplicate were it not for this guard.
                guard case nil = $0
                else
                {
                    return
                }

                let canonical:Set<GenericConstraint<Symbol.Decl>>
                do
                {
                    canonical = try self.computeConformance(where: overlapping,
                        to: target,
                        of: type)
                }
                catch let error
                {
                    switch target
                    {
                    case "ss9EscapableP":                               break // print(error)
                    case "ss8CopyableP":                                break // print(error)
                    case "s11CoreMetrics06_SwiftB16SendableProtocolP":  break // print(error)
                    default:                                            throw error
                    }

                    // print("""
                    //     Note: recovering from error due to known Apple Swift bug
                    //         https://github.com/swiftlang/swift/issues/76499

                    //     """)
                    return
                }

                //  Generate an implicit, internal extension for this conformance,
                //  if one does not already exist.
                self.extensions[extending: type, where: canonical].add(conformance: target,
                    by: culture)
                $0 = canonical

            } (&type.conformances[target])
        }

        //  We don’t need this table anymore.
        type.conformanceStatements = [:]
    }
}
extension SSGC.TypeChecker
{
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
            if  let decl:SSGC.DeclObject = self.declarations[visible: symbol]
            {
                heir = decl
            }
            else
            {
                return
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

            guard
            let conditions:Set<GenericConstraint<Symbol.Decl>> = heir.conformances[conformance]
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
    }
}
extension SSGC.TypeChecker
{
    public consuming
    func load(in culture:Symbol.Module) throws -> SSGC.ModuleIndex
    {
        var resolvableLinks:UCF.ResolutionTable<UCF.CausalOverload> = self.allModules.reduce(
            into: [:])
        {
            $0.register($1)
        }

        var reexported:[Symbol.Decl] = []
        for decl:SSGC.DeclObject in self.declarations.all
        {
            /// The target may have been re-exported from multiple modules. Swift allows
            /// re-exported declarations to be accessed under any of the re-exporting module
            /// qualifiers, so we also need to add the declaration under all of its namespaces.
            let target:UCF.CausalOverload = .decl(decl.value)
            for namespace:Symbol.Module in decl.namespaces
            {
                resolvableLinks[namespace, decl.value.path].append(target)
            }

            if  decl.culture != culture, decl.namespaces.contains(culture)
            {
                reexported.append(decl.id)
            }
        }

        for `extension`:SSGC.ExtensionObject in self.extensions.all
        {
            //  We add the feature paths here and not in `insert(_:by:)` because those
            //  edges are frequently duplicated, and it is hard to remove duplicate paths
            //  after they have been added.
            let extendee:SSGC.DeclObject = try self.declarations[`extension`.extendee]
            for feature:Symbol.Decl in `extension`.features.keys
            {
                let feature:SSGC.Decl = try self.declarations[feature].value
                let last:String = feature.path.last

                let target:UCF.CausalOverload = .feature(feature, self: extendee.id)
                for namespace:Symbol.Module in extendee.namespaces
                {
                    resolvableLinks[namespace, extendee.value.path, last].append(target)
                }
            }
        }

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
            resolvableModules: self.allModules,
            resolvableLinks: resolvableLinks,
            declarations: self.declarations.load(culture: culture),
            extensions: extensions,
            reexports: reexported,
            features: features)
    }
}
