#if canImport(IndexStoreDB)

import class IndexStoreDB.IndexStoreDB
import MarkdownPluginSwift
import Sources
import Symbols

extension IndexStoreDB: Markdown.SwiftLanguage.IndexStore {
    public func load(
        for id: String,
        utf8: [UInt8]
    ) -> [Int: Markdown.SwiftLanguage.IndexMarker] {
        let locallyDeclared: Set<String> = self.symbols(inFilePath: id).reduce(into: []) {
            $0.insert($1.usr)
        }

        //  Compute line positions
        var lines: [Int: Int] = [1: utf8.startIndex]
        var line: Int = 1
        for (i, byte): (Int, UInt8) in zip(utf8.indices, utf8) {
            if  byte == 0x0A {
                line += 1
                lines[line] = utf8.index(after: i)
            }
        }

        var markers: [Int: Markdown.SwiftLanguage.IndexMarker] = [:]
        for occurence: IndexStoreDB.SymbolOccurrence_ in self.symbolOccurrences(
                inFilePath: id
            ) {
            guard
            let position: SourcePosition = .init(
                line: occurence.location.line - 1,
                column: occurence.location.utf8Column - 1
            ),
            let base: Int = lines[occurence.location.line],
            let usr: Symbol.USR = .init(occurence.symbol.usr) else {
                continue
            }

            let phylum: Phylum.Decl?

            if  occurence.roles.contains(.implicit) {
                phylum = nil
            } else {
                switch occurence.symbol.kind {
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
                case .destructor:           phylum = .deinitializer
                case .conversionFunction:   phylum = nil
                case .parameter:            phylum = nil
                case .using:                phylum = nil
                case .concept:              phylum = nil
                case .commentTag:           phylum = nil
                }
            }

            {
                let stacked: Markdown.SwiftLanguage.IndexMarker = .init(
                    position: position,
                    symbol: locallyDeclared.contains(occurence.symbol.usr) ? nil : usr,
                    phylum: phylum
                )

                guard
                let marker: Markdown.SwiftLanguage.IndexMarker = $0 else {
                    $0 = stacked
                    return
                }

                switch marker.phylum {
                case .actor, .associatedtype, .class, .enum, .protocol, .struct, .typealias:
                    return

                default:
                    $0 = stacked
                }

            } (&markers[base + occurence.location.utf8Column - 1])

        }

        return markers
    }
}

#endif
