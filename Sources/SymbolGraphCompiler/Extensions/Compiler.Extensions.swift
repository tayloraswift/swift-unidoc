import Generics
import LexicalPaths
import SymbolGraphParts

extension Compiler
{
    public
    struct Extensions
    {
        /// Extensions indexed by signature.
        private
        var groups:[Extension.Signature: ExtensionReference]
        /// Extensions indexed by block symbol. Extensions are made up of
        /// many constituent extension blocks, so multiple block symbols can
        /// point to the same extension.
        private
        var named:[Symbol.Block: ExtensionReference]

        init()
        {
            self.groups = [:]
            self.named = [:]
        }
    }
}
extension Compiler.Extensions
{
    public
    func load() -> [Compiler.Extension]
    {
        self.groups.values.map(\.value).sorted { $0.signature < $1.signature }
    }
}
extension Compiler.Extensions
{
    mutating
    func include(block:__owned Symbol.Block,
        extending type:Symbol.Scalar,
        with description:SymbolDescription,
        in context:Compiler.SourceContext) throws
    {
        guard case .block = description.phylum
        else
        {
            //  One way of looking at this is the symbol has the wrong phylum.
            //  But since we use the USR to infer symbol phylum, another
            /// explanation is that the symbol has a wrong USR.
            throw Compiler.SymbolError.init(invalid: .block(block))
        }

        let `extension`:Compiler.ExtensionReference = self(type,
            where: description.extension.conditions,
            path: description.path)
        
        if  let block:Compiler.Extension.Block = .init(
                location: try description.location?.map(context.resolve(uri:)),
                comment: description.doccomment.flatMap(context.filter(doccomment:)))
        {
            `extension`.append(block: block)
        }

        self.named[block] = `extension`
    }
}

extension Compiler.Extensions
{
    func named(_ block:Symbol.Block) throws -> Compiler.ExtensionReference
    {
        if let named:Compiler.ExtensionReference = self.named[block]
        {
            return named
        }
        else
        {
            throw Compiler.UndefinedBlockError.init(undefined: block)
        }
    }
}
extension Compiler.Extensions
{
    mutating
    func callAsFunction(_ extended:Compiler.ScalarReference,
        where conditions:[GenericConstraint<Symbol.Scalar>]) -> Compiler.ExtensionReference
    {
        self(extended.resolution, where: conditions, path: extended.value.path)
    }
    private mutating
    func callAsFunction(_ extended:Symbol.Scalar,
        where conditions:[GenericConstraint<Symbol.Scalar>],
        path:LexicalPath) -> Compiler.ExtensionReference
    {
        let signature:Compiler.Extension.Signature = .init(extended, where: conditions)
        return { $0 }(&self.groups[signature, default: .init(value: .init(
            signature: signature,
            path: .init(path)))])
    }
}
