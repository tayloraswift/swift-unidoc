import SymbolGraphParts
import Symbols

extension SSGC.TypeChecker
{
    struct Culture
    {
        let id:Symbol.Module
        let language:Phylum.Language
        let index:Int
        private
        let root:Symbol.FileBase?

        init(id:Symbol.Module,
            language:Phylum.Language,
            index:Int,
            root:Symbol.FileBase?)
        {
            self.id = id
            self.language = language
            self.index = index
            self.root = root
        }
    }
}
extension SSGC.TypeChecker.Culture
{
    func resolve(uri:String) throws -> Symbol.File
    {
        if  let root:Symbol.FileBase = self.root
        {
            try root.rebase(uri: uri)
        }
        else
        {
            throw SSGC.UnexpectedSymbolError.file(uri: uri)
        }
    }

    func filter(doccomment:SymbolGraphPart.Vertex.Doccomment) -> SSGC.DocumentationComment?
    {
        switch doccomment.culture
        {
        case nil, self.id?: .init(doccomment.text, at: doccomment.start)
        default:            nil
        }
    }
}
