#if canImport(IndexStoreDB)

import IndexStoreDB
import MarkdownPluginSwift

extension IndexStoreDB:Markdown.SwiftLanguage.IndexStore
{
    public
    func load(for id:String)
    {
        for symbol:Symbol in self.symbols(inFilePath: id)
        {
            for occurence:SymbolOccurrence in self.occurrences(ofUSR: symbol.usr, roles: .all)
            {
                print(occurence)
            }
        }
    }
}

#endif
