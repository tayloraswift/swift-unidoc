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
    // public
    // func load() -> [SSGC.Extension]
    // {
    //     self.groups.values.map(\.value).sorted { $0.signature < $1.signature }
    // }
}
extension SSGC.Extensions
{
    mutating
    func include(_ vertex:SymbolGraphPart.Vertex,
        extending type:__owned Symbol.Decl,
        namespace:Symbol.Module,
        culture:Symbol.Module)
    {
        guard
        case .block(let symbol) = vertex.usr,
        case .block = vertex.phylum
        else
        {
            fatalError("vertex is not an extension block!")
        }

        let signature:SSGC.ExtensionSignature = .init(
            extending: .init(namespace: namespace, type: type),
            where: vertex.extension.conditions)

        let extensionObject:SSGC.ExtensionObject = self[signature, path: vertex.path]

        if  let extensionBlock:SSGC.Extension.Block = .init(
                location: vertex.location,
                comment: vertex.doccomment.map { .init($0.text, at: $0.start) } ?? nil)
        {
            extensionObject.blocks.append(extensionBlock)
        }

        self.named[symbol] = extensionObject
    }
}

extension SSGC.Extensions
{
    subscript(named block:Symbol.Block) -> SSGC.ExtensionObject
    {
        get throws
        {
            if  let named:SSGC.ExtensionObject = self.named[block]
            {
                return named
            }
            else
            {
                throw SSGC.UndefinedSymbolError.block(block)
            }
        }
    }
}
extension SSGC.Extensions
{
    subscript(extending extended:SSGC.DeclObject,
        where conditions:[GenericConstraint<Symbol.Decl>]) -> SSGC.ExtensionObject
    {
        mutating get
        {
            let signature:SSGC.ExtensionSignature = .init(
                extending: .init(namespace: extended.namespace, type: extended.id),
                where: conditions)
            return self[signature, path: extended.value.path]
        }
    }

    private
    subscript(signature:SSGC.ExtensionSignature,
        path path:UnqualifiedPath) -> SSGC.ExtensionObject
    {
        mutating get
        {
            {
                if  let object:SSGC.ExtensionObject = $0
                {
                    return object
                }
                else
                {
                    let object:SSGC.ExtensionObject = .init(signature: signature, path: path)
                    $0 = object
                    return object
                }
            }(&self.groups[signature])
        }
    }
}
