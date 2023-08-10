import HTML
import LexicalPaths
import MarkdownRendering
import Signatures
import Unidoc
import UnidocRecords

struct Tabulator
{
    let inliner:Inliner

    let libraries:[Library]
    let topics:[Record.Group.Topic]

    private
    init(_ inliner:Inliner, libraries:[Library], topics:[Record.Group.Topic])
    {
        self.inliner = inliner

        self.libraries = libraries
        self.topics = topics
    }
}
extension Tabulator
{
    init(_ inliner:__owned Inliner,
        generics:__shared [GenericParameter],
        groups:__shared [Record.Group])
    {
        let libraries:[Library] = groups.reduce(into: [:] as [Party: [Record.Group.Extension]])
        {
            guard case .extension(let `extension`) = $1
            else
            {
                return
            }

            let party:Party
            if  `extension`.id.zone == inliner.zones.principal.id
            {
                party = .first
            }
            else if let zone:Record.Zone = inliner.zones[`extension`.id.zone]
            {
                party = .third(zone.package)
            }
            else
            {
                return
            }

            $0[party, default: []].append(`extension`)
        }
        .map
        {
            .init(extensions: .init(partitioning: $0.value, generics: generics), party: $0.key)
        }
        .sorted
        {
            $0.party < $1.party
        }

        let topics:[Record.Group.Topic] = groups.compactMap
        {
            if  case .topic(let topic) = $0
            {
                return topic
            }
            else
            {
                return nil
            }
        }
        .sorted
        {
            $0.id < $1.id
        }

        self.init(inliner, libraries: libraries, topics: topics)
    }
}
extension Tabulator:HyperTextOutputStreamable
{
    public static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        for topic:Record.Group.Topic in self.topics
        {
            html[.section, { $0.class = "group topic" }]
            {
                let containsPrincipal:Bool = topic.members.contains
                {
                    switch $0
                    {
                    case .scalar(let scalar):   return scalar == self.inliner.masters.principal
                    case .text:                 return false
                    }
                }
                if  containsPrincipal
                {
                    $0[.h2] = "See Also"
                }
                else
                {
                    $0 ?= topic.overview.map(self.inliner.passage(overview:))
                }
                $0[.ul]
                {
                    for member:Record.Link in topic.members
                    {
                        switch member
                        {
                        case .scalar(let scalar):   $0 ?= self.inliner.card(scalar)
                        case .text(let text):       $0[.li] { $0[.span] { $0[.code] = text } }
                        }
                    }
                }
            }
        }

        for library:Library in self.libraries
        {
            for `extension`:Record.Group.Extension in
                [library.extensions.generic, library.extensions.concrete].joined()
            {
                html[.section, { $0.class = "group extension" }]
                {
                    $0[.h3]
                    {
                        $0 += "Extension in "
                        $0 ?= self.inliner.link(module: `extension`.culture)
                    }
                    $0[.code, { $0.class = "constraints" }]
                    {
                        var first:Bool = true
                        for constraint:GenericConstraint<Unidoc.Scalar?> in
                            `extension`.conditions
                        {
                            if  first
                            {
                                first = false
                                $0[.span] { $0.highlight = .keyword } = "where"
                                $0 += " "
                            }
                            else
                            {
                                $0 += ", "
                            }

                            $0[.span] { $0.highlight = .typealias } = constraint.noun

                            switch constraint.what
                            {
                            case    .conformer,
                                    .subclass:  $0 += ":"
                            case    .equal:     $0 += " == "
                            }

                            $0[.span, { $0.highlight = .type }]
                            {
                                switch constraint.whom
                                {
                                case .nominal(let scalar):
                                    if  let scalar:Unidoc.Scalar,
                                        let link:HTML.Link<String> = self.inliner.link(
                                            decl: scalar)
                                    {
                                        $0 += link
                                    }
                                    else
                                    {
                                        $0 += "(redacted, \(scalar as Any))"
                                    }

                                case .complex(let text):
                                    $0 += text
                                }
                            }
                        }
                    }

                    $0[.ul]
                    {
                        for conformance:Unidoc.Scalar in `extension`.conformances
                        {
                            $0 ?= self.inliner.card(conformance)
                        }
                    }
                    $0[.ul]
                    {
                        for nested:Unidoc.Scalar in `extension`.nested
                        {
                            $0 ?= self.inliner.card(nested)
                        }
                    }
                    $0[.ul]
                    {
                        for feature:Unidoc.Scalar in `extension`.features
                        {
                            $0 ?= self.inliner.card(feature)
                        }
                    }
                    $0[.ul]
                    {
                        for subform:Unidoc.Scalar in `extension`.subforms
                        {
                            $0 ?= self.inliner.card(subform)
                        }
                    }
                }
            }
        }
    }
}
