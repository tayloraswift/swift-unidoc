import HTML
import LexicalPaths
import MarkdownRendering
import Signatures
import SymbolGraphs
import Symbols
import Unidoc
import UnidocRecords

extension Swiftinit
{
    struct GroupLists
    {
        let context:IdentifiablePageContext<Swiftinit.Vertices>

        private
        var requirements:[Unidoc.Scalar]
        private
        var inhabitants:[Unidoc.Scalar]
        private
        var superforms:[Unidoc.Scalar]
        private
        var products:[Unidoc.Scalar]
        private
        var modules:[Unidoc.Scalar]
        private
        var others:[Unidoc.Scalar]

        private
        var topics:[Unidoc.TopicGroup]
        private
        var extensions:[Unidoc.ExtensionGroup]

        private(set)
        var peerConstraints:[GenericConstraint<Unidoc.Scalar?>]
        private(set)
        var peerList:[Unidoc.Scalar]

        private
        let decl:Phylum.DeclFlags?
        private
        let bias:Bias

        private
        init(_ context:IdentifiablePageContext<Swiftinit.Vertices>,
            decl:Phylum.DeclFlags?,
            bias:Bias)
        {
            self.context = context

            self.requirements = []
            self.inhabitants = []
            self.superforms = []
            self.products = []
            self.modules = []
            self.others = []

            self.topics = []
            self.extensions = []
            self.peerConstraints = []
            self.peerList = []

            self.decl = decl
            self.bias = bias
        }
    }
}
extension Swiftinit.GroupLists
{
    init(_ context:IdentifiablePageContext<Swiftinit.Vertices>,
        groups:[Unidoc.AnyGroup],
        vertex:borrowing Unidoc.DeclVertex,
        bias:Swiftinit.Bias) throws
    {
        self.init(context, decl: vertex.flags, bias: bias)

        self.requirements = vertex._requirements
        self.superforms = vertex.superforms

        try self.organize(groups: consume groups,
            container: vertex.peers,
            generics: .init(vertex.signature.generics.parameters))
    }

    init(_ context:IdentifiablePageContext<Swiftinit.Vertices>,
        groups:[Unidoc.AnyGroup],
        decl:Phylum.DeclFlags? = nil,
        bias:Swiftinit.Bias) throws
    {
        self.init(context, decl: decl, bias: bias)

        try self.organize(groups: consume groups)
    }
}
extension Swiftinit.GroupLists
{
    private mutating
    func organize(groups:[Unidoc.AnyGroup],
        container:Unidoc.Group? = nil,
        generics:Generics = .init([])) throws
    {
        var extensions:[(Unidoc.ExtensionGroup, Partisanship, Genericness)] = []
        var curated:Set<Unidoc.Scalar> = [self.context.id]

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

                let partisanship:Partisanship = self.context[secondary: group.id.edition]
                    .map
                {
                    .third($0.symbol.package)
                } ?? .first

                let genericness:Genericness = group.constraints.isEmpty ?
                    .unconstrained : generics.count(substituting: group.constraints) > 0 ?
                    .constrained :
                    .concretized

                extensions.append((group, partisanship, genericness))

            case .intrinsic(let group):
                if  case group.id? = container
                {
                    self.peerList = group.members
                    continue
                }

                switch self.decl?.phylum
                {
                case .protocol?:
                    self.requirements += group.members

                case .enum?:
                    self.inhabitants += group.members

                default:
                    throw Unidoc.GroupTypeError.reject(.intrinsic(group))
                }

            case .polygonal(let group):
                guard
                let first:Unidoc.Scalar = group.members.first,
                let plane:SymbolGraph.Plane = first.plane
                else
                {
                    continue
                }

                if  first == self.context.id,
                    group.members.count == 1
                {
                    //  This is a polygon that contains this page only.
                    continue
                }

                //  Guess what kind of polygon this is by looking at the bit pattern of its
                //  first vertex.
                switch plane
                {
                case .product:  self.products += group.members
                case .module:   self.modules += group.members
                default:        self.others += group.members
                }

            case .topic(let group):
                for case .scalar(let scalar) in group.members
                {
                    curated.insert(scalar)
                }

                self.topics.append(group)

            case let unexpected:
                throw Unidoc.GroupTypeError.reject(unexpected)
            }
        }

        extensions.sort
        {
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
            ($0.1, $0.0.culture.citizen, $0.2, $0.0.id) <
            ($1.1, $1.0.culture.citizen, $1.2, $1.0.id)
        }

        self.extensions = extensions.map { $0.0.subtracting(curated) }

        self.requirements.removeAll(where: curated.contains(_:))
        self.inhabitants.removeAll(where: curated.contains(_:))
        self.superforms.removeAll(where: curated.contains(_:))
        self.products.removeAll(where: curated.contains(_:))
        self.modules.removeAll(where: curated.contains(_:))
        self.others.removeAll(where: curated.contains(_:))
        self.peerList.removeAll(where: curated.contains(_:))

        self.topics.sort { $0.id < $1.id }
    }
}
extension Swiftinit.GroupLists:HTML.OutputStreamable
{
    static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        var other:Unidoc.TopicGroup? = nil
        for group:Unidoc.TopicGroup in self.topics
        {
            if  group.members.contains(.scalar(self.context.id))
            {
                guard group.members.count > 1
                else
                {
                    //  This is a topic group that contains this page only.
                    //  A “See Also” section is not necessary.
                    continue
                }

                other = group
            }
            else
            {
                //  This is a topic group that doesn’t contain this page. It is not a “See Also”
                //  section, and we should render any caption associated with it.
                html[.section]
                {
                    $0.class = "group topic"
                } = Swiftinit.Topic.init(self.context,
                    caption: group.overview,
                    members: group.members)
            }
        }

        if  let body:Swiftinit.SegregatedBody = .init(self.context, group: self.others)
        {
            //  If this is an uncategorized section, let’s categorize it.
            html[.section]
            {
                $0.class = "group segregated"
            } = Swiftinit.CollapsibleSection<Swiftinit.SegregatedBody>.init(
                heading: .uncategorized,
                body: body)
        }

        let sections:[(AutomaticHeading, [Unidoc.Scalar])]
        if  case .package = self.bias
        {
            sections =
            [
                (.allModules, self.modules),
                (.allProducts, self.products),
            ]
        }
        else
        {
            sections =
            [
                (.otherModules, self.modules),
                (.otherProducts, self.products),
            ]
        }
        for (heading, members):(AutomaticHeading, [Unidoc.Scalar]) in sections
            where !members.isEmpty
        {
            //  Cannot use a ``SegregatedList`` here, because these are not decls.
            html[.section, { $0.class = "group automatic" }]
            {
                $0[.h2] = heading
                $0[.ul]
                {
                    for member:Unidoc.Scalar in members
                    {
                        $0[.li] = self.context.card(member)
                    }
                }
            }
        }

        if  let decl:Phylum.DeclFlags = self.decl,
            let body:Swiftinit.SegregatedList = .init(self.context, group: self.superforms)
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
            } = Swiftinit.CollapsibleSection<Swiftinit.SegregatedList>.init(
                heading: heading,
                body: body)
        }
        if  let body:Swiftinit.SegregatedList = .init(self.context, group: self.inhabitants)
        {
            html[.section]
            {
                $0.class = "group inhabitants"
            } = Swiftinit.CollapsibleSection<Swiftinit.SegregatedList>.init(
                heading: .allCases,
                body: body)
        }
        if  let body:Swiftinit.SegregatedBody = .init(self.context, group: self.requirements)
        {
            html[.section]
            {
                $0.class = "group segregated requirements"
            } = Swiftinit.CollapsibleSection<Swiftinit.SegregatedBody>.init(
                heading: .allRequirements,
                body: body)
        }

        let extensionsEmpty:Bool = self.extensions.allSatisfy(\.isEmpty)

        if  let other:Unidoc.TopicGroup
        {
            let last:Bool = self.peerList.isEmpty && extensionsEmpty
            let open:Bool = other.members.count <= 12

            html[.section]
            {
                $0.class = "group topic"
            } = Swiftinit.CollapsibleSection<Swiftinit.Topic>.init(
                collapse: last ? nil : (other.members.count, open),
                heading: .seeAlso,
                body: .init(self.context, members: other.members))
        }

        guard
        let decl:Phylum.DeclFlags = self.decl
        else
        {
            //  The rest of the sections are only relevant for declarations.
            return
        }

        if  case .case = decl.phylum,
            let peers:Swiftinit.SegregatedList = .init(self.context, group: self.peerList)
        {
            let open:Bool = peers.visible.count <= 12

            html[.section]
            {
                $0.class = "group sisters"
            } = Swiftinit.CollapsibleSection<Swiftinit.SegregatedList>.init(
                collapse: extensionsEmpty ? nil : (self.peerList.count, open),
                heading: .otherCases,
                body: peers)
        }
        else if
            let peers:Swiftinit.SegregatedBody = .init(self.context, group: self.peerList)
        {
            let open:Bool = peers.visibleItems <= 12

            html[.section]
            {
                $0.class = "group segregated sisters"
            } = Swiftinit.CollapsibleSection<Swiftinit.SegregatedBody>.init(
                collapse: extensionsEmpty ? nil : (self.peerList.count, open),
                heading: decl.kinks[is: .required] ? .otherRequirements : .otherMembers,
                body: peers)
        }

        for group:Unidoc.ExtensionGroup in self.extensions
        {
            html[.section]
            {
                $0.class = "group segregated extension"
            } = Swiftinit.ExtensionSection.init(self.context,
                group: group,
                decl: decl,
                bias: self.bias)
        }
    }
}
