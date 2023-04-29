import CodelinkResolution
import MarkdownABI
import MarkdownParsing
import MarkdownSemantics
import SymbolGraphCompiler

extension CodelinkResolver
{
    func link(
        documentation:Compiler.Documentation) -> SymbolGraph.Article<SymbolGraph.Referent>
    {
        self.link(comment: documentation.comment, scope: documentation.scope)
    }
    func link(
        comment:Compiler.Documentation.Comment,
        scope:[String]) -> SymbolGraph.Article<SymbolGraph.Referent>
    {
        let markdown:MarkdownDocumentation = .init(parsing: comment.text,
            as: SwiftFlavoredMarkdown.self)

        var references:[Codelink: UInt32] = [:]
        var referents:[SymbolGraph.Referent] = []
        var fold:Int = referents.endIndex
        
        markdown.visit
        {
            if  $0 is MarkdownDocumentation.Fold
            {
                fold = referents.endIndex
                return
            }

            $0.outline
            {
                (expression:String) -> UInt32? in

                guard let codelink:Codelink = .init(parsing: expression)
                else
                {
                    print("invalid codelink '\(expression)'")
                    return nil
                }

                let reference:UInt32? =
                {
                    if  let reference:UInt32 = $0
                    {
                        return reference
                    }

                    let referent:SymbolGraph.Referent
                    switch self.query(ascending: scope, link: codelink)
                    {
                    case nil:
                        referent = .unresolved(codelink)
                    
                    case .one(let overload)?:
                        switch overload.target
                        {
                        case .scalar(let address):
                            referent = .scalar(address)
                        
                        case .vector(let address, self: let heir):
                            referent = .vector(address, self: heir)
                        }
                    
                    case .many?:
                        print("ambiguous codelink '\(codelink)'")
                        return nil
                    }

                    let next:UInt32 = .init(referents.endIndex)
                    referents.append(referent)
                    $0 = next
                    return next

                } (&references[codelink])

                return reference
            }
        }

        let binary:MarkdownBinary = .init(from: markdown)
        return .init(markdown: binary.bytes, links: referents, fold: fold)
    }
}
