import ModuleGraphs
import Symbols
import SymbolGraphParts

extension Compiler
{
    struct Culture
    {
        let id:ModuleIdentifier
        let index:Int
        let root:Repository.Root?

        init(id:ModuleIdentifier, index:Int, root:Repository.Root?)
        {
            self.id = id
            self.index = index
            self.root = root
        }
    }
}
extension Compiler.Culture
{
    func resolve(uri:String) throws -> FileSymbol
    {
        guard   let root:Repository.Root = self.root
        else
        {
            throw Compiler.UnexpectedSymbolError.file(uri: uri)
        }
        guard   var start:String.Index = uri.index(uri.startIndex,
                    offsetBy: 7,
                    limitedBy: uri.endIndex),
                uri[..<start] == "file://"
        else
        {
            throw Compiler.InvalidSymbolError.file(uri: uri)
        }
        for character:Character in root.path
        {
            if  start < uri.endIndex, uri[start] == character
            {
                start = uri.index(after: start)
            }
            else
            {
                throw Compiler.InvalidSymbolError.file(uri: uri)
            }
        }

        return .init(.init(uri[start...].drop { $0 == "/" }))
    }

    func filter(doccomment:SymbolDescription.Doccomment) -> Compiler.Documentation.Comment?
    {
        switch doccomment.culture
        {
        case nil, self.id?: return .init(doccomment.text, at: doccomment.start)
        default:            return nil
        }
    }
}
