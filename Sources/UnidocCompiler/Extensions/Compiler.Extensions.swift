import Generics
import LexicalPaths
import Symbols
import SymbolGraphParts

extension Compiler
{
    public
    struct Extensions
    {
        /// Extensions indexed by signature.
        private
        var groups:[Extension.Signature: ExtensionObject]
        /// Extensions indexed by block symbol. Extensions are made up of
        /// many constituent extension blocks, so multiple block symbols can
        /// point to the same extension.
        private
        var named:[BlockSymbol: ExtensionObject]

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
    func include(block:__owned BlockSymbol,
        extending type:ScalarSymbol,
        with description:SymbolDescription,
        in context:Compiler.Context) throws
    {
        guard case .block = description.phylum
        else
        {
            //  One way of looking at this is the symbol has the wrong phylum.
            //  But since we use the USR to infer symbol phylum, another
            /// explanation is that the symbol has a wrong USR.
            throw Compiler.UnexpectedSymbolError.block(block)
        }

        let `extension`:Compiler.ExtensionObject = self(context.culture.index, type,
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
    func named(_ block:BlockSymbol) throws -> Compiler.ExtensionObject
    {
        if let named:Compiler.ExtensionObject = self.named[block]
        {
            return named
        }
        else
        {
            throw Compiler.UndefinedSymbolError.block(block)
        }
    }
}
extension Compiler.Extensions
{
    mutating
    func callAsFunction(_ culture:Int, _ extended:Compiler.ScalarObject,
        where conditions:[GenericConstraint<ScalarSymbol>]) -> Compiler.ExtensionObject
    {
        self(culture, extended.id, where: conditions, path: extended.value.path)
    }
    private mutating
    func callAsFunction(_ culture:Int, _ extended:ScalarSymbol,
        where conditions:[GenericConstraint<ScalarSymbol>],
        path:LexicalPath) -> Compiler.ExtensionObject
    {
        let signature:Compiler.Extension.Signature = .init(culture, extended, where: conditions)
        return { $0 }(&self.groups[signature, default: .init(value: .init(
            signature: signature,
            path: .init(path)))])
    }
}
