import HTML
import Signatures
import Unidoc

extension Inliner
{
    struct ExtensionHeader
    {
        let inliner:Inliner

        private
        let display:String
        private
        let culture:Unidoc.Scalar
        private
        let `where`:[GenericConstraint<Unidoc.Scalar?>]

        init(_ inliner:Inliner,
            display:String,
            culture:Unidoc.Scalar,
            where:[GenericConstraint<Unidoc.Scalar?>])
        {
            self.inliner = inliner
            self.display = display
            self.culture = culture
            self.where = `where`
        }
    }
}
extension Inliner.ExtensionHeader:HyperTextOutputStreamable
{
    static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        html[.h2]
        {
            $0 += self.display
            $0 ?= self.inliner.link(module: self.culture)
        }
        if  self.where.isEmpty
        {
            return
        }
        html[.code, { $0.class = "constraints" }]
        {
            var first:Bool = true
            for constraint:GenericConstraint<Unidoc.Scalar?> in self.where
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
                    case .complex(let text):
                        $0 += text

                    case .nominal(let scalar):
                        if  let scalar:Unidoc.Scalar,
                            let link:HTML.Link<String> = self.inliner.link(
                                decl: scalar)
                        {
                            $0 += link
                        }
                        else if
                            let scalar:Unidoc.Scalar
                        {
                            $0 += "(redacted, \(scalar))"
                        }
                        else
                        {
                            $0 += "(redacted)"
                        }
                    }
                }
            }
        }
    }
}
