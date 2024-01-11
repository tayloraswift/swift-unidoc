import HTML
import LexicalPaths
import MarkdownRendering
import Signatures
import SymbolGraphs
import Unidoc
import UnidocRecords

extension Swiftinit
{
    struct GroupLists
    {
        let context:IdentifiablePageContext<Swiftinit.Vertices>

        private
        let requirements:[Unidoc.Scalar]?
        private
        let superforms:[Unidoc.Scalar]?

        private
        var extensions:[Unidoc.ExtensionGroup]
        private
        var topics:[Unidoc.TopicGroup]
        private
        var other:[(AutomaticHeading, [Unidoc.Scalar])]

        private(set)
        var peers:Unidoc.ExtensionGroup?

        private
        let bias:Bias
        private
        let mode:GroupListMode?

        private
        init(_ context:IdentifiablePageContext<Swiftinit.Vertices>,
            requirements:[Unidoc.Scalar]?,
            superforms:[Unidoc.Scalar]?,
            extensions:[Unidoc.ExtensionGroup] = [],
            topics:[Unidoc.TopicGroup] = [],
            other:[(AutomaticHeading, [Unidoc.Scalar])] = [],
            peers:Unidoc.ExtensionGroup? = nil,
            bias:Bias,
            mode:GroupListMode?)
        {
            self.context = context

            self.requirements = requirements
            self.superforms = superforms
            self.extensions = extensions
            self.topics = topics
            self.other = other
            self.peers = peers
            self.bias = bias
            self.mode = mode
        }
    }
}
extension Swiftinit.GroupLists
{
    init(_ context:IdentifiablePageContext<Swiftinit.Vertices>,
        organizing groups:/*consuming*/ [Unidoc.AnyGroup],
        vertex:borrowing Unidoc.DeclVertex? = nil,
        bias:Swiftinit.Bias,
        mode:Swiftinit.GroupListMode? = nil) throws
    {
        let container:Unidoc.Group?
        let generics:Generics
        if  let vertex:Unidoc.DeclVertex = copy vertex
        {
            self.init(consume context,
                requirements: vertex.requirements.isEmpty ? nil : vertex.requirements,
                superforms: vertex.superforms.isEmpty ? nil : vertex.superforms,
                bias: bias,
                mode: mode)

            container = vertex.extension
            generics = .init(vertex.signature.generics.parameters)
        }
        else
        {
            self.init(consume context,
                requirements: nil,
                superforms: nil,
                bias: bias,
                mode: mode)

            container = nil
            generics = .init([])
        }

        var extensions:[(Unidoc.ExtensionGroup, Partisanship, Genericness)] = []
        var curated:Set<Unidoc.Scalar> = [self.context.id]

        for group:Unidoc.AnyGroup in groups
        {
            switch group
            {
            case .extension(let group):
                if  case group.id? = container
                {
                    self.peers = group
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
                switch (plane, self.mode)
                {
                case (.product, .meta): heading = .allProducts
                case (.product, _):     heading = .otherProducts
                case (.module, .meta):  heading = .allModules
                case (.module, _):      heading = .otherModules
                default:                heading = .miscellaneous
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
        self.peers = self.peers.map { $0.subtracting(curated) }
        self.extensions = extensions.map { $0.0.subtracting(curated) }

        self.topics.sort { $0.id < $1.id }
        self.other.sort { $0.0 < $1.0 }
    }
}
extension Swiftinit.GroupLists
{
    private
    func list(_ scalars:__owned [Unidoc.Scalar],
        under heading:String? = nil) -> Swiftinit.GroupList?
    {
        scalars.isEmpty ? nil : .init(self.context, heading: heading, scalars: scalars)
    }
}

extension Swiftinit.GroupLists:HTML.OutputStreamable
{
    static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        for group:Unidoc.TopicGroup in self.topics
        {
            guard group.members.contains(.scalar(self.context.id))
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

                continue
            }

            if  group.members.count == 1
            {
                //  This is a topic group that contains this page only.
                //  A “See Also” section is not necessary.
                continue
            }

            html[.section, { $0.class = "group topic" }]
            {
                AutomaticHeading.seeAlso.window(&$0,
                    listing: group.members,
                    limit: 12)
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

        guard case .decl(let phylum, let kinks)? = self.mode
        else
        {
            return
        }

        if  let superforms:[Unidoc.Scalar] = self.superforms
        {
            html[.section, { $0.class = "group superforms" }]
            {
                let heading:AutomaticHeading

                if      kinks[is: .required]
                {
                    heading = .restatesRequirements
                }
                else if kinks[is: .intrinsicWitness]
                {
                    heading = .implementsRequirements
                }
                else if kinks[is: .override]
                {
                    heading = .overrides
                }
                else if case .class = phylum
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
                    for superform:Unidoc.Scalar in superforms
                    {
                        $0[.li] = self.context.card(superform)
                    }
                }
            }
        }

        if  let requirements:[Unidoc.Scalar] = self.requirements
        {
            html[.section, { $0.class = "group requirements" }]
            {
                let heading:AutomaticHeading = .allRequirements

                $0[.h2] = heading
                $0[.ul]
                {
                    for requirement:Unidoc.Scalar in requirements
                    {
                        $0[.li] = self.context.card(requirement)
                    }
                }
            }
        }

        if  let peers:Unidoc.ExtensionGroup = self.peers, !peers.nested.isEmpty
        {
            html[.section, { $0.class = "group sisters" }]
            {
                AutomaticHeading.otherMembers.window(&$0,
                    listing: peers.nested,
                    limit: 12,
                    open: self.extensions.allSatisfy(\.isEmpty))
                {
                    $0[.li] = self.context.card($1)
                }
            }
        }

        for group:Unidoc.ExtensionGroup in self.extensions where !group.isEmpty
        {
            html[.section, { $0.class = "group extension" }]
            {
                $0[.h2] = Swiftinit.ExtensionHeader.init(self.context,
                    heading: .init(culture: group.culture, bias: self.bias))

                $0[.div, .code]
                {
                    $0.class = "constraints"
                } = Swiftinit.ConstraintsList.init(self.context, constraints: group.constraints)

                $0 ?= self.list(group.conformances, under: "Conformances")
                $0 ?= self.list(group.nested, under: "Members")
                $0 ?= self.list(group.features, under: "Features")

                switch phylum
                {
                case .protocol:
                    $0 ?= self.list(group.subforms, under: "Subtypes")

                case .class:
                    $0 ?= self.list(group.subforms, under: "Subclasses")

                case _:
                    if  kinks[is: .required]
                    {
                        let (restatements, witnesses):([Unidoc.Scalar], [Unidoc.Scalar]) =
                            group.subforms.reduce(into: ([], []))
                        {
                            if  case .decl(let decl)? = self.context[$1],
                                decl.kinks[is: .intrinsicWitness]
                            {
                                $0.1.append($1)
                            }
                            else
                            {
                                $0.0.append($1)
                            }
                        }

                        $0 ?= self.list(restatements, under: "Restated By")
                        $0 ?= self.list(witnesses, under: "Default Implementations")
                    }
                    else
                    {
                        $0 ?= self.list(group.subforms, under: "Overridden By")
                    }
                }
            }
        }
    }
}
