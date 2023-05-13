import PackageGraphs
import Symbols
import SymbolGraphParts

extension Compiler
{
    struct Context
    {
        let culture:(id:ModuleIdentifier, index:Int)
        let root:Repository.Root?

        init(culture:(id:ModuleIdentifier, index:Int), root:Repository.Root?)
        {
            self.culture = culture
            self.root = root
        }
    }
}
extension Compiler.Context
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
        case nil, self.culture.id?: return .init(doccomment.text, at: doccomment.start)
        default:                    return nil
        }
    }
}
