import SymbolDescriptions

extension Compiler
{
    struct Context
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
extension Compiler.Context
{
    func resolve(uri:String) throws -> FileIdentifier
    {
        guard   var start:String.Index = uri.index(uri.startIndex,
                    offsetBy: 7,
                    limitedBy: uri.endIndex),
                uri[..<start] == "file://"
        else
        {
            throw Compiler.FileIdentifierError.init(invalid: uri)
        }
        for character:Character in self.root.path
        {
            if  start < uri.endIndex, uri[start] == character
            {
                start = uri.index(after: start)
            }
            else
            {
                throw Compiler.FileIdentifierError.init(invalid: uri)
            }
        }
        
        return .init(.init(uri[start...].drop { $0 == "/" }))
    }

    func filter(documentation:SymbolDescription.Documentation) -> String?
    {
        switch documentation.culture
        {
        case nil, self.culture?:    return documentation.comment
        default:                    return nil
        }
    }
}
