import HTML
import Symbols

extension Unidoc
{
    /// Generates fake code containing an import statement.
    struct ImportSection
    {
        let module:Symbol.Module

        init(module:Symbol.Module)
        {
            self.module = module
        }
    }
}
extension Unidoc.ImportSection:HTML.OutputStreamable
{
    static
    func += (code:inout HTML.ContentEncoder, self:Self)
    {
        code[.span] { $0.highlight = .keyword } = "import"
        code += " "
        code[.span] { $0.highlight = .identifier } = self.module
    }
}

