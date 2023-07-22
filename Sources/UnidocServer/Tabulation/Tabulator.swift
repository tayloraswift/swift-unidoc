import HTML
import LexicalPaths
import Signatures
import Unidoc
import UnidocRecords

struct Tabulator
{
    let libraries:[Library]
    let inliner:Inliner

    private
    init(libraries:[Library], inliner:Inliner)
    {
        self.libraries = libraries
        self.inliner = inliner
    }
}
extension Tabulator
{
    init(
        extensions:__shared [Record.Extension],
        generics:__shared [GenericParameter],
        inliner:__owned Inliner)
    {
        let libraries:[Library] = extensions.reduce(into: [:] as [Party: [Record.Extension]])
        {
            let party:Party
            if  $1.id.zone == inliner.zones.principal.id
            {
                party = .first
            }
            else if let zone:Record.Zone.Names = inliner.zones[$1.id.zone]
            {
                party = .third(zone.package)
            }
            else
            {
                return
            }

            $0[party, default: []].append($1)
        }
        .map
        {
            .init(extensions: .init(partitioning: $0.value, generics: generics), party: $0.key)
        }
        .sorted
        {
            $0.party < $1.party
        }

        self.init(libraries: libraries, inliner: inliner)
    }
}
extension Tabulator:HyperTextOutputStreamable
{
    public static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        for library:Library in self.libraries
        {
            for `extension`:Record.Extension in
                [library.extensions.generic, library.extensions.concrete].joined()
            {
                html[.section, { $0.class = "extension" }]
                {
                    $0[.h3]
                    {
                        $0 += "(extension in "
                        $0 ?= self.inliner.link(module: `extension`.culture)
                        $0 += ")"
                    }
                    var first:Bool = true
                    for constraint:GenericConstraint<Unidoc.Scalar?> in `extension`.conditions
                    {
                        $0[.code]
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
                            switch constraint.whom
                            {
                            case .nominal(let scalar):
                                if  let scalar:Unidoc.Scalar,
                                    let link:HTML.Link<UnqualifiedPath> = self.inliner.link(
                                        decl: scalar)
                                {
                                    $0 += link
                                }
                                else
                                {
                                    $0 += "(redacted, \(scalar as Any))"
                                }

                            case .complex(let text):
                                $0[.span] { $0.highlight = .literal } = text
                            }
                        }
                    }

                    $0[.ul]
                    {
                        for conformance:Unidoc.Scalar in `extension`.conformances
                        {
                            $0[.li] = self.inliner.card(conformance)
                        }
                    }
                    $0[.ul]
                    {
                        for nested:Unidoc.Scalar in `extension`.nested
                        {
                            $0[.li] = self.inliner.card(nested)
                        }
                    }
                    $0[.ul]
                    {
                        for feature:Unidoc.Scalar in `extension`.features
                        {
                            $0[.li] = self.inliner.card(feature)
                        }
                    }
                    $0[.ul]
                    {
                        for subform:Unidoc.Scalar in `extension`.subforms
                        {
                            $0[.li] = self.inliner.card(subform)
                        }
                    }
                }
            }
        }
    }
}
