import HTML
import LexicalPaths
import ModuleGraphs
import MarkdownRendering
import Signatures
import Unidoc
import UnidocRecords

struct GroupSections
{
    let context:IdentifiablePageContext<Unidoc.Scalar>

    private
    let requirements:[Unidoc.Scalar]?
    private
    let superforms:[Unidoc.Scalar]?

    private
    var extensions:[Volume.Group.Extension]
    private
    var topics:[Volume.Group.Topic]
    private
    var other:[(AutomaticHeading, [Unidoc.Scalar])]

    private
    let bias:Unidoc.Scalar?
    private
    let mode:Mode?

    private
    init(_ context:IdentifiablePageContext<Unidoc.Scalar>,
        requirements:[Unidoc.Scalar]?,
        superforms:[Unidoc.Scalar]?,
        extensions:[Volume.Group.Extension] = [],
        topics:[Volume.Group.Topic] = [],
        other:[(AutomaticHeading, [Unidoc.Scalar])] = [],
        bias:Unidoc.Scalar?,
        mode:Mode?)
    {
        self.context = context

        self.requirements = requirements
        self.superforms = superforms
        self.extensions = extensions
        self.topics = topics
        self.other = other
        self.bias = bias
        self.mode = mode
    }
}
extension GroupSections
{
    init(_ context:IdentifiablePageContext<Unidoc.Scalar>,
        requirements:[Unidoc.Scalar] = [],
        superforms:[Unidoc.Scalar] = [],
        generics:[GenericParameter] = [],
        groups:consuming [Volume.Group],
        bias:Unidoc.Scalar? = nil,
        mode:Mode? = nil)
    {
        let generics:Generics = .init(generics)

        self.init(context,
            requirements: requirements.isEmpty ? nil : requirements,
            superforms: superforms.isEmpty ? nil : superforms,
            bias: bias,
            mode: mode)

        var extensions:[(Volume.Group.Extension, Partisanship, Genericness)] = []
        var curated:Set<Unidoc.Scalar> = []

        for group:Volume.Group in copy groups
        {
            switch group
            {
            case .extension(let group):
                let partisanship:Partisanship = context.volumes.secondary[group.id.zone].map
                {
                    .third($0.symbol.package)
                } ?? .first

                let genericness:Genericness = group.conditions.isEmpty ?
                    .unconstrained : generics.count(substituting: group.conditions) > 0 ?
                    .constrained :
                    .concretized

                extensions.append((group, partisanship, genericness))

            case .automatic(let group):
                //  Guess what kind of autogroup this is by looking at the bit pattern of
                //  the first member of the group.
                guard
                let first:Unidoc.Scalar = group.members.first,
                let plane:UnidocPlane = .of(first.citizen)
                else
                {
                    continue
                }

                if  first == self.context.id,
                    group.members.count == 1
                {
                    //  This is an automatic group that contains this page only.
                    continue
                }

                let heading:AutomaticHeading

                switch (plane, self.mode)
                {
                case (.module, .meta):  heading = .allModules
                case (.module, _):      heading = .otherModules
                case (_, _):            heading = .miscellaneous
                }

                self.other.append((heading, group.members))

            case .topic(let group):
                for case .scalar(let scalar) in group.members
                {
                    curated.insert(scalar)
                }

                self.topics.append(group)
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

        self.topics.sort { $0.id < $1.id }
    }
}
extension GroupSections
{
    private
    func heading(for extension:Volume.Group.Extension) -> ExtensionHeading
    {
        let display:String
        switch (self.bias, self.bias?.zone)
        {
        case (`extension`.culture?, _): display = "Citizens in "
        case (_, `extension`.id.zone?): display = "Available in "
        case (_,                    _): display = "Extension in "
        }

        return .init(self.context,
            display: display,
            culture: `extension`.culture,
            where: `extension`.conditions)
    }

    private
    func list(_ scalars:__owned [Unidoc.Scalar], under heading:String? = nil) -> GroupList?
    {
        if  scalars.isEmpty
        {
            return nil
        }
        else
        {
            return .init(self.context, heading: heading, scalars: scalars)
        }
    }
}

extension GroupSections:HyperTextOutputStreamable
{
    static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        for group:Volume.Group.Topic in self.topics
        {
            guard group.members.contains(.scalar(self.context.id))
            else
            {
                //  This is a topic group that doesn’t contain this page.
                //  It is not a “See Also” section, and we should render
                //  any prose associated with it.
                html[.section, { $0.class = "group topic" }]
                {
                    $0 ?= group.overview.map(self.context.prose(overview:))

                    $0[.ul]
                    {
                        self.context.list(members: group.members, to: &$0)
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
                let heading:AutomaticHeading = .seeAlso

                $0[.h2] { $0.id = heading.id } = heading

                guard group.members.count > 12
                else
                {
                    $0[.ul]
                    {
                        self.context.list(members: group.members, to: &$0)
                    }

                    return
                }

                $0[.details]
                {
                    $0[.summary]
                    {
                        $0[.p] { $0.class = "view" } = "View members"

                        $0[.p] { $0.class = "hide" } = "Hide members"

                        $0[.p, { $0.class = "reason" }]
                        {
                            $0 += """
                            This section is hidden by default because it contains too many \

                            """

                            $0[.span] { $0.class = "count" } = "(\(group.members.count))"

                            $0 += """
                                members.
                            """
                        }
                    }
                    $0[.ul]
                    {
                        self.context.list(members: group.members, to: &$0)
                    }
                }
            }
        }

        for (heading, members):(AutomaticHeading, [Unidoc.Scalar]) in self.other
        {
            html[.section, { $0.class = "group automatic" }]
            {
                $0[.h2] { $0.id = heading.id } = heading
                $0[.ul]
                {
                    for member:Unidoc.Scalar in members
                    {
                        $0 ?= self.context.card(member)
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

                $0[.h2] { $0.id = heading.id } = heading
                $0[.ul]
                {
                    for superform:Unidoc.Scalar in superforms
                    {
                        $0 ?= self.context.card(superform)
                    }
                }
            }
        }

        if  let requirements:[Unidoc.Scalar] = self.requirements
        {
            html[.section, { $0.class = "group requirements" }]
            {
                let heading:AutomaticHeading = .allRequirements

                $0[.h2] { $0.id = heading.id } = heading
                $0[.ul]
                {
                    for requirement:Unidoc.Scalar in requirements
                    {
                        $0 ?= self.context.card(requirement)
                    }
                }
            }
        }

        for group:Volume.Group.Extension in self.extensions
        {
            html[.section, { $0.class = "group extension" }]
            {
                $0 += self.heading(for: group)

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
                            if  case true? =
                                self.context.vertices[$1]?.decl?.kinks[is: .intrinsicWitness]
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