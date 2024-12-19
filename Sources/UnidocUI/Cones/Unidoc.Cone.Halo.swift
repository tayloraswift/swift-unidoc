import HTML
import LexicalPaths
import MarkdownRendering
import Signatures
import SymbolGraphs
import Symbols
import Unidoc
import UnidocRecords

extension Unidoc.Cone
{
    struct Halo
    {
        let context:Unidoc.InternalPageContext

        private
        var uncategorized:[Unidoc.Scalar]

        private
        var requirements:[Unidoc.Scalar]
        private
        var inhabitants:[Unidoc.Scalar]
        private
        var superforms:[Unidoc.Scalar]
        private
        var curation:[Unidoc.Scalar]
        private
        var products:[Unidoc.Scalar]
        private
        var modules:[Unidoc.Scalar]

        private
        var extensions:[[Unidoc.ExtensionGroup]]

        private(set)
        var peerConstraints:[GenericConstraint<Unidoc.Scalar>]
        private(set)
        var peerList:[Unidoc.Scalar]

        private
        let decl:Phylum.DeclFlags?
        private
        let bias:Unidoc.Bias

        private
        init(_ context:Unidoc.InternalPageContext,
            decl:Phylum.DeclFlags?,
            bias:Unidoc.Bias)
        {
            self.context = context

            self.uncategorized = []
            self.requirements = []
            self.inhabitants = []
            self.superforms = []
            self.curation = []
            self.products = []
            self.modules = []

            self.extensions = []
            self.peerConstraints = []
            self.peerList = []

            self.decl = decl
            self.bias = bias
        }
    }
}
extension Unidoc.Cone.Halo
{
    init(_ context:Unidoc.InternalPageContext,
        curated:consuming Set<Unidoc.Scalar>,
        groups:borrowing [Unidoc.AnyGroup],
        apex:borrowing Unidoc.DeclVertex) throws
    {
        self.init(context, decl: apex.flags, bias: apex.bias)

        self.requirements = apex._requirements
        self.superforms = apex.superforms

        try self.organize(groups: groups,
            excluding: consume curated,
            container: apex.peers,
            generics: .init(apex.signature.generics.parameters))
    }

    init(_ context:Unidoc.InternalPageContext,
        curated:consuming Set<Unidoc.Scalar>,
        groups:borrowing [Unidoc.AnyGroup],
        decl:Phylum.DeclFlags? = nil,
        bias:Unidoc.Bias) throws
    {
        self.init(context, decl: decl, bias: bias)

        try self.organize(groups: groups, excluding: consume curated)
    }
}
extension Unidoc.Cone.Halo
{
    private mutating
    func organize(groups:[Unidoc.AnyGroup],
        excluding curated:consuming Set<Unidoc.Scalar>,
        container:Unidoc.Group? = nil,
        generics:Generics = .init([])) throws
    {
        var extensions:[Unidoc.ExtendingModule: [Unidoc.ExtensionGroup]] = [:]
        for group:Unidoc.AnyGroup in groups
        {
            switch group
            {
            case .extension(let group):
                if  case group.id? = container
                {
                    self.peerConstraints = group.constraints
                    self.peerList = group.nested
                    continue
                }

                let module:Unidoc.ExtendingModule

                if  let volume:Unidoc.VolumeMetadata = self.context[secondary: group.id.edition]
                {
                    module = .init(partisanship: .third(volume.symbol.package),
                        index: group.culture.id.citizen)
                }
                else
                {
                    module = .init(partisanship: .first,
                        index: group.culture.id.citizen)
                }

                extensions[module, default: []].append(group)

            case .intrinsic(let group):
                if  case group.id? = container
                {
                    self.peerList = group.items
                    continue
                }

                switch self.decl?.phylum
                {
                case .protocol?:
                    self.requirements += group.items

                case .enum?:
                    self.inhabitants += group.items

                default:
                    throw Unidoc.GroupTypeError.reject(.intrinsic(group))
                }

            case .curator(let group):
                guard
                let first:Unidoc.Scalar = group.items.first,
                let plane:SymbolGraph.Plane = first.plane
                else
                {
                    continue
                }

                //  Guess what kind of polygon this is by looking at the bit pattern of its
                //  first vertex.
                switch plane
                {
                case .product:
                    self.products += group.items

                case .module:
                    self.modules += group.items

                default:
                    if  case nil = group.scope
                    {
                        self.curation += group.items
                        //  We’re not filtering these, so we need to remove these members from
                        //  any other groups that might also contain them.
                        //
                        //  This logic probably needs to be revisited.
                        curated.formUnion(group.items)
                    }
                    else
                    {
                        self.uncategorized += group.items
                    }
                }

            case let unexpected:
                throw Unidoc.GroupTypeError.reject(unexpected)
            }
        }

        //  Prevent the currently-shown page from appearing in the “See Also” section.
        let apex:Unidoc.Scalar = self.context.id

        curated.insert(apex)
        self.curation.removeAll { $0 == apex }

        //  Sort libraries by partisanship, first-party first, then third-party
        //  by package identifier.
        //  Then, break ties by extension culture. Module numbers are
        //  lexicographically ordered according to the package’s internal dependency
        //  graph, so the library with the lowest module number will always be the
        //  current culture, if it is present.
        //  Then, break ties by genericness. Generic extensions come first, concrete
        //  extensions come last.
        //  Finally, break ties by extension id. This is arbitrary, but we usually try
        //  to assign id numbers such that the extensions with the fewest constraints
        //  come first.
        let extendingModules:[Unidoc.ExtendingModule] = extensions.keys.sorted()

        self.extensions = extendingModules.map
        {
            var groups:[(Unidoc.ExtensionGroup, Generality)] = extensions.removeValue(
                forKey: $0)?.map
            {
                let genericness:Generality = $0.constraints.isEmpty ?
                    .unconstrained : generics.count(substituting: $0.constraints) > 0 ?
                    .constrained :
                    .concretized
                return ($0, genericness)
            } ?? []

            groups.sort { ($0.1, $0.0.id) < ($1.1, $1.0.id) }
            return groups.map { $0.0.subtracting(curated) }
        }

        self.uncategorized.removeAll(where: curated.contains(_:))
        self.requirements.removeAll(where: curated.contains(_:))
        self.inhabitants.removeAll(where: curated.contains(_:))
        self.superforms.removeAll(where: curated.contains(_:))
        self.products.removeAll(where: curated.contains(_:))
        self.modules.removeAll(where: curated.contains(_:))
        self.peerList.removeAll(where: curated.contains(_:))
    }
}
extension Unidoc.Cone.Halo:HTML.OutputStreamable
{
    static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        if  let uncategorized:Unidoc.SegregatedBody = .init(group: self.uncategorized,
                name: "uncategorized",
                with: self.context)
        {
            //  This is an uncategorized section, so let’s categorize it.
            html[.section]
            {
                $0.class = "group segregated"
            } = Unidoc.CollapsibleSection<Unidoc.SegregatedBody>.init(
                heading: .uncategorized,
                content: uncategorized)
        }

        if  let modules:Unidoc.IntegratedList = .init(items: self.modules,
                with: self.context)
        {
            html[.section]
            {
                $0.class = "group automatic"
            } = Unidoc.CollapsibleSection<Unidoc.IntegratedList>.init(
                heading: self.bias == .package ? .allModules : .otherModules,
                content: modules)
        }
        if  let products:Unidoc.IntegratedList = .init(items: self.products,
                with: self.context)
        {
            html[.section]
            {
                $0.class = "group automatic"
            } = Unidoc.CollapsibleSection<Unidoc.IntegratedList>.init(
                heading: self.bias == .package ? .allProducts : .otherProducts,
                content: products)
        }

        if  let decl:Phylum.DeclFlags = self.decl,
            let body:Unidoc.SegregatedList = .init(group: self.superforms,
                with: self.context)
        {
            let heading:AutomaticHeading

            if      decl.kinks[is: .required]
            {
                heading = .restatesRequirements
            }
            else if decl.kinks[is: .intrinsicWitness]
            {
                heading = .implementsRequirements
            }
            else if decl.kinks[is: .override]
            {
                heading = .overrides
            }
            else if case .class = decl.phylum
            {
                heading = .superclasses
            }
            else
            {
                heading = .supertypes
            }

            html[.section]
            {
                $0.class = "group superforms"
            } = Unidoc.CollapsibleSection<Unidoc.SegregatedList>.init(
                heading: heading,
                content: body)
        }
        if  let body:Unidoc.SegregatedList = .init(group: self.inhabitants,
                with: self.context)
        {
            html[.section]
            {
                $0.class = "group inhabitants"
            } = Unidoc.CollapsibleSection<Unidoc.SegregatedList>.init(
                heading: .allCases,
                content: body)
        }
        if  let body:Unidoc.SegregatedBody = .init(group: self.requirements,
                name: "requirements",
                with: self.context)
        {
            html[.section]
            {
                $0.class = "group segregated requirements"
            } = Unidoc.CollapsibleSection<Unidoc.SegregatedBody>.init(
                heading: .allRequirements,
                content: body)
        }

        let extensionsEmpty:Bool = self.extensions.allSatisfy(\.isEmpty)

        if  let curation:Unidoc.IntegratedList = .init(items: self.curation,
                with: self.context)
        {
            let last:Bool = self.peerList.isEmpty && extensionsEmpty

            html[.section]
            {
                $0.class = "group topic"
            } = Unidoc.CollapsibleSection<Unidoc.IntegratedList>.init(
                heading: .seeAlso,
                content: curation,
                window: last ? nil : 12 ... 12)
        }

        guard
        let decl:Phylum.DeclFlags = self.decl
        else
        {
            //  The rest of the sections are only relevant for declarations.
            return
        }

        if  case .case = decl.phylum,
            let peers:Unidoc.SegregatedList = .init(group: self.peerList, with: self.context)
        {
            html[.section]
            {
                $0.class = "group sisters"
            } = Unidoc.CollapsibleSection<Unidoc.SegregatedList>.init(
                heading: .otherCases,
                content: peers,
                window: extensionsEmpty ? nil : 12 ... 12)
        }
        else if
            let peers:Unidoc.SegregatedBody = .init(group: self.peerList, with: self.context)
        {
            html[.section]
            {
                $0.class = "group segregated sisters"
            } = Unidoc.CollapsibleSection<Unidoc.SegregatedBody>.init(
                heading: decl.kinks[is: .required] ? .otherRequirements : .otherMembers,
                content: peers,
                //  If there are 8–12 members, and this is not the last section, this section
                //  will be collapsible, but open by default.
                window: extensionsEmpty ? nil : 8 ... 12)
        }

        for extensions:[Unidoc.ExtensionGroup] in self.extensions
        {
            var culture:Unidoc.LinkReference<Unidoc.CultureVertex>?
            var module:Symbol.Module?

            for group:Unidoc.ExtensionGroup in extensions where !group.isEmpty
            {
                culture = culture ?? self.context[culture: group.culture]

                guard
                let culture:Unidoc.LinkReference<Unidoc.CultureVertex>
                else
                {
                    continue
                }

                //  We only set the section landmark for the first extension group from
                //  a given culture.
                let moduleLeader:Bool
                let moduleSymbol:Symbol.Module

                if  let module:Symbol.Module
                {
                    moduleLeader = false
                    moduleSymbol = module
                }
                else
                {
                    moduleLeader = true
                    moduleSymbol = culture.vertex.module.id
                    module = moduleSymbol
                }

                html[.section]
                {
                    $0.class = "group segregated extension"
                    $0.id = moduleLeader ? "sm:\(moduleSymbol)" : nil
                }
                    content:
                {
                    let header:Unidoc.ExtensionHeader = .init(extension: group,
                        culture: culture,
                        module: moduleSymbol,
                        bias: self.bias,
                        with: self.context)

                    $0[.header] = header
                    $0 += Unidoc.ExtensionBody.init(extension: group,
                        decl: decl,
                        name: header.name,
                        with: self.context)
                }
            }
        }
    }
}
