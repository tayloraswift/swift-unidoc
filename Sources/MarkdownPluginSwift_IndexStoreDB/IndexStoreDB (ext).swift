#if canImport(IndexStoreDB)

import class IndexStoreDB.IndexStoreDB
import MarkdownPluginSwift
import Sources
import Symbols

extension IndexStoreDB:Markdown.SwiftLanguage.IndexStore
{
    public
    func load(for id:String, utf8:[UInt8]) -> [Int: Markdown.SwiftLanguage.IndexMarker]
    {
        //  Compute line positions
        var lines:[Int: Int] = [1: utf8.startIndex]
        var line:Int = 1
        for (i, byte):(Int, UInt8) in zip(utf8.indices, utf8)
        {
            if  byte == 0x0A
            {
                line += 1
                lines[line] = utf8.index(after: i)
            }
        }

        var markers:[Int: Markdown.SwiftLanguage.IndexMarker] = [:]
        for symbol:IndexStoreDB.Symbol_ in self.symbols(inFilePath: id)
        {
            for occurence:IndexStoreDB.SymbolOccurrence_ in self.occurrences(ofUSR: symbol.usr,
                roles: .all)
            {
                guard
                let position:SourcePosition = .init(line: occurence.location.line - 1,
                    column: occurence.location.utf8Column - 1),
                let base:Int = lines[occurence.location.line],
                let usr:Symbol.USR = .init(symbol.usr)
                else
                {
                    continue
                }

                let phylum:Phylum.Decl?

                switch symbol.kind
                {
                case .constructor:
                    phylum = occurence.roles.contains(.call)
                        ? .func(.static)
                        : .initializer

                case .unknown:              phylum = nil
                case .module:               phylum = nil
                case .namespace:            phylum = nil
                case .namespaceAlias:       phylum = nil
                case .macro:                phylum = nil
                case .enum:                 phylum = .enum
                case .struct:               phylum = .struct
                case .class:                phylum = .class
                case .protocol:             phylum = .protocol
                case .extension:            phylum = .typealias
                case .union:                phylum = .enum
                case .typealias:            phylum = .typealias
                case .function:             phylum = .func(nil)
                case .variable:             phylum = .var(nil)
                case .field:                phylum = nil
                case .enumConstant:         phylum = .case
                case .instanceMethod:       phylum = .func(.instance)
                case .classMethod:          phylum = .func(.class)
                case .staticMethod:         phylum = .func(.static)
                case .instanceProperty:     phylum = .var(.instance)
                case .classProperty:        phylum = .var(.class)
                case .staticProperty:       phylum = .var(.static)
                case .constructor:          phylum = .initializer
                case .destructor:           phylum = .deinitializer
                case .conversionFunction:   phylum = nil
                case .parameter:            phylum = nil
                case .using:                phylum = nil
                case .concept:              phylum = nil
                case .commentTag:           phylum = nil
                }

                markers[base + occurence.location.utf8Column - 1] = .init(position: position,
                    symbol: usr,
                    phylum: phylum)
            }
        }

        return markers
    }
}

#endif
