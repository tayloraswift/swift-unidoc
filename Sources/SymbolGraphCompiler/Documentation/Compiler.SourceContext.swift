import Repositories
import Symbols
import SymbolGraphParts

extension Compiler
{
    struct SourceContext
    {
        let culture:ModuleIdentifier
        let root:Repository.Root

        init(culture:ModuleIdentifier, root:Repository.Root)
        {
            self.culture = culture
            self.root = root
        }
    }
}
extension Compiler.SourceContext
{
    func resolve(uri:String) throws -> FileSymbol
    {
        guard   var start:String.Index = uri.index(uri.startIndex,
                    offsetBy: 7,
                    limitedBy: uri.endIndex),
                uri[..<start] == "file://"
        else
        {
            throw Compiler.SourceFileError.init(invalid: uri)
        }
        for character:Character in self.root.path
        {
            if  start < uri.endIndex, uri[start] == character
            {
                start = uri.index(after: start)
            }
            else
            {
                throw Compiler.SourceFileError.init(invalid: uri)
            }
        }
        
        return .init(.init(uri[start...].drop { $0 == "/" }))
    }

    func filter(doccomment:SymbolDescription.Doccomment) -> Compiler.Documentation.Comment?
    {
        switch doccomment.culture
        {
        case nil, self.culture?:    return .init(doccomment.text, at: doccomment.start)
        default:                    return nil
        }
    }
}
