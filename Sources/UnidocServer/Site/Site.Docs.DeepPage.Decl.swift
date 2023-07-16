import HTML
import LexicalPaths
import Signatures
import Unidoc
import UnidocRecords
import URI

extension Site.Docs.DeepPage
{
    struct Decl
    {
        let master:Record.Master.Decl
        let extensions:[Record.Extension]

        private
        let inliner:Inliner

        init(_ master:Record.Master.Decl,
            extensions:[Record.Extension],
            inliner:Inliner)
        {
            self.master = master
            self.extensions = extensions
            self.inliner = inliner
        }
    }
}
extension Site.Docs.DeepPage.Decl
{
    var zone:Record.Zone.Names
    {
        self.inliner.zones.principal.zone
    }

    var location:URI
    {
        .init(decl: self.master, in: self.zone)
    }
}
extension Site.Docs.DeepPage.Decl:HyperTextOutputStreamable
{
    public static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        guard let path:QualifiedPath = .init(splitting: self.master.stem)
        else
        {
            return
        }

        html[.head]
        {
            //  TODO: this should include the package name
            $0[.title] = path.last
        }
        html[.body]
        {
            $0[.section, { $0.class = "introduction \(self.master.customization.accent)" }]
            {
                $0[.div, { $0.class = "eyebrows" }]
                {
                    $0[.span, { $0.class = "phylum" }] = self.master.phylum.title

                    $0[.span, { $0.class = "module" }]
                    {
                        $0 ?= self.master.namespace == self.master.culture ? nil
                            : self.inliner.link(module: self.master.culture)

                        $0[link: self.inliner.uri(self.master.namespace)] = path.namespace
                    }
                }

                $0[.h1] = path.last

                $0 ?= self.master.overview.map(self.inliner.prose(_:))

                $0[.span, { $0.class = "phylum" }] = self.master.customization.title
            }

            $0[.section, { $0.class = "declaration" }]
            {
                $0[.pre]
                {
                    $0[.code] = self.inliner.code(self.master.signature.expanded)
                }
            }

            $0[.section] { $0.class = "details" } =
                self.master.details.map(self.inliner.prose(_:))

            $0[.section, { $0.class = "superforms" }]
            {
                $0[.ul]
                {
                    for superform:Unidoc.Scalar in self.master.superforms
                    {
                        $0[.li] = self.inliner.card(superform)
                    }
                }
            }

            for `extension`:Record.Extension in self.extensions
            {
                $0[.section, { $0.class = "extension" }]
                {
                    for constraint:GenericConstraint<Unidoc.Scalar?> in `extension`.conditions
                    {
                        $0[.code]
                        {
                            $0[.span] { $0.highlight = .keyword } = "where"
                            $0 += " "
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
