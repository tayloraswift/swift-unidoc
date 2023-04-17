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
    func resolve(location:SymbolDescription.Location) -> Compiler.Location?
    {
        guard   let position:SymbolGraph.Location.Position = .init(line: location.line,
            column: location.column),
        var start:String.Index = location.uri.index(location.uri.startIndex,
            offsetBy: 7,
            limitedBy: location.uri.endIndex),
        location.uri[..<start] == "file://"
        else
        {
            return nil
        }
        for character:Character in self.root.path
        {
            if  start < location.uri.endIndex, location.uri[start] == character
            {
                start = location.uri.index(after: start)
            }
            else
            {
                return nil
            }
        }
        let relative:Substring = location.uri[start...].drop { $0 == "/" }

        return .init(position: position, file: .init(.init(relative)))
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
