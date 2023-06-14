import Codelinks
import CodelinkResolution
import MarkdownABI
import MarkdownParsing
import MarkdownSemantics
import SymbolGraphs
import UnidocCompiler

extension StaticLinker
{
    struct Outliner
    {
        private
        let resolver:StaticResolver
        private
        let scope:[String]

        private(set)
        var references:[Codelink: UInt32]
        private(set)
        var referents:[SymbolGraph.Referent]

        init(resolver:StaticResolver, scope:[String])
        {
            self.resolver = resolver
            self.scope = scope

            self.references = [:]
            self.referents = []
        }
    }
}
extension StaticLinker.Outliner
{
    mutating
    func outline(expression:String) -> UInt32?
    {
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
            switch self.resolver.query(ascending: self.scope, link: codelink)
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
                print("Codelink '\(codelink)' is ambiguous.")
                return nil
            }

            let next:UInt32 = .init(self.referents.endIndex)
            self.referents.append(referent)
            $0 = next
            return next

        } (&self.references[codelink])

        return reference
    }
}
extension StaticLinker.Outliner
{
    mutating
    func link(
        comment:Compiler.Documentation.Comment,
        adding extra:[MarkdownDocumentationSupplement]? = nil) -> SymbolGraph.Article<Never>
    {
        //  TODO: use supplements
        let documentation:MarkdownDocumentation = .init(parsing: comment.text,
            as: SwiftFlavoredMarkdownComment.self)

        let overview:MarkdownBytecode = .init
        {
            (binary:inout MarkdownBinaryEncoder) in

            documentation.overview.map
            {
                $0.outline
                {
                    self.outline(expression: $0)
                }
                $0.emit(into: &binary)
            }
        }

        let fold:Int = self.referents.endIndex

        let details:MarkdownBytecode = .init
        {
            (binary:inout MarkdownBinaryEncoder) in

            documentation.details.visit
            {
                $0.outline
                {
                    self.outline(expression: $0)
                }
                $0.emit(into: &binary)
            }
        }
        return .init(referents: self.referents,
            overview: overview,
            details: details,
            fold: fold)
    }
}
