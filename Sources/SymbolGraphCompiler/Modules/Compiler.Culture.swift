import Symbols
import SymbolGraphParts

extension Compiler
{
    struct Culture
    {
        let id:Symbol.Module
        let index:Int
        private
        let root:Symbol.FileBase?

        init(id:Symbol.Module, index:Int, root:Symbol.FileBase?)
        {
            self.id = id
            self.index = index
            self.root = root
        }
    }
}
extension Compiler.Culture
{
    func resolve(uri:String) throws -> Symbol.File
    {
        if  let root:Symbol.FileBase = self.root
        {
            try root.rebase(uri: uri)
        }
        else
        {
            throw Compiler.UnexpectedSymbolError.file(uri: uri)
        }
    }

    func filter(doccomment:SymbolGraphPart.Vertex.Doccomment) -> Compiler.Doccomment?
    {
        switch doccomment.culture
        {
        case nil, self.id?: return .init(doccomment.text, at: doccomment.start)
        default:            return nil
        }
    }
}
