import SymbolGraphParts
import Symbols
import SystemIO

extension SSGC
{
    @_spi(testable) public
    struct SymbolDumps
    {
        let modules:[Symbol.Module: SymbolFiles]

        private
        init(modules:[Symbol.Module: SymbolFiles])
        {
            self.modules = modules
        }
    }
}
extension SSGC.SymbolDumps
{
    @_spi(testable) public
    static func collect(from locations:FilePath.Directory...) throws -> Self
    {
        try .collect(from: locations)
    }

    static func collect(from locations:[FilePath.Directory]) throws -> Self
    {
        let symbols:[Symbol.Module: SSGC.SymbolFiles] = try locations.reduce(
            into: [:])
        {
            for filename:Result<FilePath.Component, any Error> in $1
            {
                //  We don’t want to *parse* the JSON yet to discover the culture,
                //  because the JSON can be very large, and parsing JSON is very
                //  expensive (compared to parsing BSON). So we trust that the file
                //  name is correct and indicates what is contained within the file.
                let filename:FilePath.Component = try filename.get()

                guard
                let id:SymbolGraphPart.ID = .init("\(filename)")
                else
                {
                    continue
                }

                switch id.namespace
                {
                case    "CDispatch",                    // too low-level
                        "CFURLSessionInterface",        // too low-level
                        "CFXMLInterface",               // too low-level
                        "CoreFoundation",               // too low-level
                        "Glibc",                        // linux-gnu specific
                        "SwiftGlibc",                   // linux-gnu specific
                        "SwiftOnoneSupport",            // contains no symbols
                        "SwiftOverlayShims",            // too low-level
                        "SwiftShims",                   // contains no symbols
                        "_Builtin_intrinsics",          // contains only one symbol, free(_:)
                        "_Builtin_stddef_max_align_t",  // contains only two symbols
                        "_InternalStaticMirror",        // unbuildable
                        "_InternalSwiftScan",           // unbuildable
                        "_SwiftConcurrencyShims",       // contains only two symbols
                        "std":                          // unbuildable
                    continue

                default:
                    $0[id.culture, default: .init(location: $1)].parts.append(id)
                }
            }
        }

        return .init(modules: symbols)
    }
}
