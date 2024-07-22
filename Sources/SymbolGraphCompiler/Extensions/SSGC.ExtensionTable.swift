import LexicalPaths
import Signatures
import SymbolGraphParts
import Symbols

extension SSGC
{
    struct ExtensionTable
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
extension SSGC.ExtensionTable
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
        //  Assume there is a possibility this culture is re-exporting another culture’s
        //  extension block.
        if  let extensionBlock:SSGC.Extension.Block = .init(
                location: vertex.location,
                comment: vertex.doccomment.map { .init($0.text, at: $0.start) } ?? nil)
        {
            { _ in }(&extensionObject.blocks[symbol, default: (extensionBlock, in: culture)])
        }

        self.named[symbol] = extensionObject
    }
}

extension SSGC.ExtensionTable
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
                throw SSGC.UndefinedSymbolError.extension(block)
            }
        }
    }
}
extension SSGC.ExtensionTable
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
extension SSGC.ExtensionTable
{
    func load(culture:Symbol.Module) -> [SSGC.Extension]
    {
        self.groups.values.reduce(into: [])
        {
            var blocks:[(id:Symbol.Block, block:SSGC.Extension.Block)] = $1.blocks.reduce(
                into: [])
            {
                if  case (let id, (let block, in: culture)) = $1
                {
                    $0.append((id, block))
                }
            }

            blocks.sort { $0.id.name < $1.id.name }

            $0.append(.init(signature: $1.signature,
                path: $1.path,
                conformances: $1.conformances.sorted(selecting: culture),
                features: $1.features.sorted(selecting: culture),
                nested: $1.nested.sorted(selecting: culture),
                blocks: blocks.map { $0.block }))
        }
    }
}
