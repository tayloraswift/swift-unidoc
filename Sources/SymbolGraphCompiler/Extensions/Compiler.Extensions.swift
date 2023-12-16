import LexicalPaths
import Signatures
import SymbolGraphParts
import Symbols

extension Compiler
{
    public
    struct Extensions
    {
        /// Extensions indexed by signature.
        private
        var groups:[ExtensionSignature: ExtensionObject]
        /// Extensions indexed by block symbol. Extensions are made up of
        /// many constituent extension blocks, so multiple block symbols can
        /// point to the same extension.
        private
        var named:[Symbol.Block: ExtensionObject]

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
    func include(block:consuming Symbol.Block,
        extending type:consuming Symbol.Decl,
        namespace:consuming Compiler.Namespace.ID,
        with vertex:SymbolGraphPart.Vertex,
        in culture:Compiler.Culture) throws
    {
        guard case .block = vertex.phylum
        else
        {
            //  One way of looking at this is the symbol has the wrong phylum.
            //  But since we use the USR to infer symbol phylum, another
            /// explanation is that the symbol has a wrong USR.
            throw Compiler.UnexpectedSymbolError.block(block)
        }

        let `extension`:Compiler.ExtensionObject = self(culture.index, .init(
                namespace: namespace,
                type: type),
            where: vertex.extension.conditions,
            path: vertex.path)

        if  let block:Compiler.Extension.Block = .init(
                location: try vertex.location?.map(culture.resolve(uri:)),
                comment: vertex.doccomment.flatMap(culture.filter(doccomment:)))
        {
            `extension`.append(block: block)
        }

        self.named[block] = `extension`
    }
}

extension Compiler.Extensions
{
    func named(_ block:Symbol.Block) throws -> Compiler.ExtensionObject
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
    func callAsFunction(_ culture:Int, _ extended:Compiler.DeclObject,
        where conditions:[GenericConstraint<Symbol.Decl>]) -> Compiler.ExtensionObject
    {
        self(culture, .init(namespace: extended.namespace, type: extended.id),
            where: conditions,
            path: extended.value.path)
    }
    private mutating
    func callAsFunction(_ culture:Int, _ extended:Compiler.ExtendedType,
        where conditions:[GenericConstraint<Symbol.Decl>],
        path:UnqualifiedPath) -> Compiler.ExtensionObject
    {
        let signature:Compiler.ExtensionSignature = .init(culture, extended, where: conditions)
        return { $0 }(&self.groups[signature, default: .init(value: .init(
            signature: signature,
            path: path))])
    }
}
