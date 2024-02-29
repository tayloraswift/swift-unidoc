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
        var extensions:[Unidoc.ExtensionGroup]
        private
        var topics:[Unidoc.TopicGroup]
        private
        var other:[(AutomaticHeading, [Unidoc.Scalar])]

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
            requirements:[Unidoc.Scalar] = [],
            inhabitants:[Unidoc.Scalar] = [],
            superforms:[Unidoc.Scalar] = [],
            extensions:[Unidoc.ExtensionGroup] = [],
            topics:[Unidoc.TopicGroup] = [],
            other:[(AutomaticHeading, [Unidoc.Scalar])] = [],
            peerConstraints:[GenericConstraint<Unidoc.Scalar?>] = [],
            peerList:[Unidoc.Scalar] = [],
            decl:Phylum.DeclFlags?,
            bias:Bias)
        {
            self.context = context

            self.requirements = requirements
            self.inhabitants = inhabitants
            self.superforms = superforms

            self.extensions = extensions
            self.topics = topics
            self.other = other
            self.peerConstraints = peerConstraints
            self.peerList = peerList

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
                let heading:AutomaticHeading

                if  case .package = self.bias
                {
                    switch plane
                    {
                    case .product:  heading = .allProducts
                    case .module:   heading = .allModules
                    default:        heading = .miscellaneous
                    }
                }
                else
                {
                    switch plane
                    {
                    case .product:  heading = .otherProducts
                    case .module:   heading = .otherModules
                    default:        heading = .miscellaneous
                    }
                }

                self.other.append((heading, group.members))

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

        //  No need to filter the conformers, as it should never appear alongside any custom
        //  curated groups.
        self.extensions = extensions.map { $0.0.subtracting(curated) }

        self.requirements.removeAll(where: curated.contains(_:))
        self.inhabitants.removeAll(where: curated.contains(_:))
        self.peerList.removeAll(where: curated.contains(_:))

        self.topics.sort { $0.id < $1.id }
        self.other.sort { $0.0 < $1.0 }
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
                //  This is a topic group that doesn’t contain this page.
                //  It is not a “See Also” section, and we should render
                //  any prose associated with it.
                html[.section, { $0.class = "group topic" }]
                {
                    $0 ?= group.overview.map { ProseSection.init(self.context, passage: $0) }

                    $0[.ul]
                    {
                        for member:Unidoc.TopicMember in group.members
                        {
                            switch member
                            {
                            case .scalar(let scalar):
                                $0[.li] = self.context.card(scalar)

                            case .text(let text):
                                $0[.li] { $0[.span] { $0[.code] = text } }
                            }
                        }
                    }
                }
            }
        }

        for (heading, members):(AutomaticHeading, [Unidoc.Scalar]) in self.other
        {
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

        guard
        let decl:Phylum.DeclFlags = self.decl
        else
        {
            return
        }

        if !self.superforms.isEmpty
        {
            html[.section, { $0.class = "group superforms" }]
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

                $0[.h2] = heading
                $0[.ul]
                {
                    for id:Unidoc.Scalar in self.superforms
                    {
                        $0[.li] = self.context.card(id)
                    }
                }
            }
        }
        if !self.requirements.isEmpty
        {
            html[.section, { $0.class = "group requirements" }]
            {
                let heading:AutomaticHeading = .allRequirements

                $0[.h2] = heading
                $0[.ul]
                {
                    for id:Unidoc.Scalar in self.requirements
                    {
                        $0[.li] = self.context.card(id)
                    }
                }
            }
        }
        if !self.inhabitants.isEmpty
        {
            html[.section, { $0.class = "group inhabitants" }]
            {
                let heading:AutomaticHeading = .allCases

                $0[.h2] = heading
                $0[.ul]
                {
                    for id:Unidoc.Scalar in self.inhabitants
                    {
                        $0[.li] = self.context.card(id)
                    }
                }
            }
        }

        let extensionsEmpty:Bool = self.extensions.allSatisfy(\.isEmpty)

        if  let other:Unidoc.TopicGroup
        {
            html[.section, { $0.class = "group topic" }]
            {
                AutomaticHeading.seeAlso.window(&$0,
                    listing: other.members,
                    limit: 12,
                    open: self.peerList.isEmpty && extensionsEmpty)
                {
                    switch $1
                    {
                    case .scalar(let scalar):
                        $0[.li] = self.context.card(scalar)

                    case .text(let text):
                        $0[.li] { $0[.span] { $0[.code] = text } }
                    }
                }
            }
        }

        if  !self.peerList.isEmpty
        {
            html[.section, { $0.class = "group sisters" }]
            {
                let heading:AutomaticHeading

                if  decl.kinks[is: .required]
                {
                    heading = .otherRequirements
                }
                else if case .case = decl.phylum
                {
                    heading = .otherCases
                }
                else
                {
                    heading = .otherMembers
                }

                heading.window(&$0,
                    listing: self.peerList,
                    limit: 12,
                    open: extensionsEmpty)
                {
                    $0[.li] = self.context.card($1)
                }
            }
        }

        for group:Unidoc.ExtensionGroup in self.extensions
        {
            html[.section]
            {
                $0.class = "group extension"
            } = Swiftinit.ExtensionGroup.init(self.context,
                group: group,
                decl: decl,
                bias: self.bias)
        }
    }
}
