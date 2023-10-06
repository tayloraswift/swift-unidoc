import HTML
import LexicalPaths
import ModuleGraphs
import MarkdownRendering
import Signatures
import Unidoc
import UnidocRecords

struct GroupSections
{
    let inliner:VersionedPageContext

    private
    let requirements:[Unidoc.Scalar]?
    private
    let superforms:[Unidoc.Scalar]?

    private
    let extensions:[Volume.Group.Extension]
    private
    let automatic:[Volume.Group.Automatic]
    private
    let topics:[Volume.Group.Topic]

    private
    let bias:Unidoc.Scalar?
    private
    let mode:Mode?

    private
    init(_ inliner:VersionedPageContext,
        requirements:[Unidoc.Scalar]?,
        superforms:[Unidoc.Scalar]?,
        extensions:[Volume.Group.Extension],
        automatic:[Volume.Group.Automatic],
        topics:[Volume.Group.Topic],
        bias:Unidoc.Scalar?,
        mode:Mode?)
    {
        self.inliner = inliner

        self.requirements = requirements
        self.superforms = superforms
        self.extensions = extensions
        self.automatic = automatic
        self.topics = topics
        self.bias = bias
        self.mode = mode
    }
}
extension GroupSections
{
    init(_ inliner:__owned VersionedPageContext,
        requirements:__owned [Unidoc.Scalar] = [],
        superforms:__owned [Unidoc.Scalar] = [],
        generics:__shared [GenericParameter] = [],
        groups:__shared [Volume.Group],
        bias:Unidoc.Scalar? = nil,
        mode:Mode? = nil)
    {
        let generics:Generics = .init(generics)

        var extensions:[(Volume.Group.Extension, Partisanship, Genericness)] = []
        var automatic:[Volume.Group.Automatic] = []
        var topics:[Volume.Group.Topic] = []

        for group:Volume.Group in groups
        {
            switch group
            {
            case .extension(let group):
                let partisanship:Partisanship = inliner.volumes.secondary[group.id.zone].map
                {
                    .third($0.symbol.package)
                } ?? .first

                let genericness:Genericness = group.conditions.isEmpty ?
                    .unconstrained : generics.count(substituting: group.conditions) > 0 ?
                    .constrained :
                    .concretized

                extensions.append((group, partisanship, genericness))

            case .automatic(let group):
                automatic.append(group)

            case .topic(let group):
                topics.append(group)
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
        automatic.sort { $0.id < $1.id }
        topics.sort { $0.id < $1.id }

        self.init(inliner,
            requirements: requirements.isEmpty ? nil : requirements,
            superforms: superforms.isEmpty ? nil : superforms,
            extensions: extensions.map(\.0),
            automatic: automatic,
            topics: topics,
            bias: bias,
            mode: mode)
    }
}
extension GroupSections
{
    private
    func header(for extension:Volume.Group.Extension) -> ExtensionHeader
    {
        let display:String
        switch (self.bias, self.bias?.zone)
        {
        case (`extension`.culture?, _): display = "Citizens in "
        case (_, `extension`.id.zone?): display = "Available in "
        case (_,                    _): display = "Extension in "
        }

        return .init(self.inliner,
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
            return .init(self.inliner, heading: heading, scalars: scalars)
        }
    }
}

extension GroupSections:HyperTextOutputStreamable
{
    static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        for group:Volume.Group.Automatic in self.automatic
        {
            html[.section, { $0.class = "group automatic" }]
            {
                $0[.h2] = self.mode == .meta ? "Modules" : "See Also"
                $0[.ul]
                {
                    for member:Unidoc.Scalar in group.members
                    {
                        $0 ?= self.inliner.card(member)
                    }
                }
            }
        }
        for group:Volume.Group.Topic in self.topics
        {
            html[.section, { $0.class = "group topic" }]
            {
                guard
                let principal:Unidoc.Scalar = self.inliner.vertices.principal,
                    group.members.contains(.scalar(principal))
                else
                {
                    $0 ?= group.overview.map(self.inliner.prose(overview:))

                    $0[.ul]
                    {
                        self.inliner.list(members: group.members, to: &$0)
                    }
                    return
                }

                $0[.h2] = "See Also"

                if  group.members.count < 13
                {
                    $0[.ul]
                    {
                        self.inliner.list(members: group.members, to: &$0)
                    }
                }
                else
                {
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
                            self.inliner.list(members: group.members, to: &$0)
                        }
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
                if      kinks[is: .required]
                {
                    $0[.h2] = "Restates"
                }
                else if kinks[is: .intrinsicWitness]
                {
                    $0[.h2] = "Implements"
                }
                else if kinks[is: .override]
                {
                    $0[.h2] = "Overrides"
                }
                else if case .class = phylum
                {
                    $0[.h2] = "Superclasses"
                }
                else
                {
                    $0[.h2] = "Supertypes"
                }

                $0[.ul]
                {
                    for superform:Unidoc.Scalar in superforms
                    {
                        $0 ?= self.inliner.card(superform)
                    }
                }
            }
        }

        if  let requirements:[Unidoc.Scalar] = self.requirements
        {
            html[.section, { $0.class = "group requirements" }]
            {
                $0[.h2] = "Requirements"
                $0[.ul]
                {
                    for requirement:Unidoc.Scalar in requirements
                    {
                        $0 ?= self.inliner.card(requirement)
                    }
                }
            }
        }

        for group:Volume.Group.Extension in self.extensions
        {
            html[.section, { $0.class = "group extension" }]
            {
                $0 += self.header(for: group)

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
                                self.inliner.vertices[$1]?.decl?.kinks[is: .intrinsicWitness]
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