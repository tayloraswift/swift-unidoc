import LexicalPaths
import Signatures
import SymbolGraphParts
import Symbols

extension SSGC
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
extension SSGC.Extensions
{
    public
    func load() -> [SSGC.Extension]
    {
        self.groups.values.map(\.value).sorted { $0.signature < $1.signature }
    }
}
extension SSGC.Extensions
{
    mutating
    func include(block:consuming Symbol.Block,
        extending type:consuming Symbol.Decl,
        namespace:consuming SSGC.Namespace.ID,
        with vertex:SymbolGraphPart.Vertex,
        in culture:SSGC.TypeChecker.Culture) throws
    {
        guard case .block = vertex.phylum
        else
        {
            //  One way of looking at this is the symbol has the wrong phylum.
            //  But since we use the USR to infer symbol phylum, another
            /// explanation is that the symbol has a wrong USR.
            throw SSGC.UnexpectedSymbolError.block(block)
        }

        let `extension`:SSGC.ExtensionObject = self(culture.index, .init(
                namespace: namespace,
                type: type),
            where: vertex.extension.conditions,
            path: vertex.path)

        if  let block:SSGC.Extension.Block = .init(
                location: try vertex.location?.map(culture.resolve(uri:)),
                comment: vertex.doccomment.flatMap(culture.filter(doccomment:)))
        {
            `extension`.append(block: block)
        }

        self.named[block] = `extension`
    }
}

extension SSGC.Extensions
{
    func named(_ block:Symbol.Block) throws -> SSGC.ExtensionObject
    {
        if let named:SSGC.ExtensionObject = self.named[block]
        {
            return named
        }
        else
        {
            throw SSGC.UndefinedSymbolError.block(block)
        }
    }
}
extension SSGC.Extensions
{
    mutating
    func callAsFunction(_ culture:Int, _ extended:SSGC.DeclObject,
        where conditions:[GenericConstraint<Symbol.Decl>]) -> SSGC.ExtensionObject
    {
        self(culture, .init(namespace: extended.namespace, type: extended.id),
            where: conditions,
            path: extended.value.path)
    }
    private mutating
    func callAsFunction(_ culture:Int, _ extended:SSGC.ExtendedType,
        where conditions:[GenericConstraint<Symbol.Decl>],
        path:UnqualifiedPath) -> SSGC.ExtensionObject
    {
        let signature:SSGC.ExtensionSignature = .init(culture, extended, where: conditions)
        return { $0 }(&self.groups[signature, default: .init(value: .init(
            signature: signature,
            path: path))])
    }
}
