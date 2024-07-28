import SymbolGraphParts
import Symbols
import System

extension SSGC
{
    @_spi(testable) public
    struct SymbolDumps
    {
        let location:FilePath.Directory
        let modules:[Symbol.Module: [SymbolGraphPart.ID]]

        private
        init(location:FilePath.Directory, modules:[Symbol.Module: [SymbolGraphPart.ID]])
        {
            self.location = location
            self.modules = modules
        }
    }
}
extension SSGC.SymbolDumps
{
    @_spi(testable) public
    static func collect(from location:FilePath.Directory) throws -> Self
    {
        let symbols:[Symbol.Module: [SymbolGraphPart.ID]] = try location.reduce(
            into: [:])
        {
            //  We don’t want to *parse* the JSON yet to discover the culture,
            //  because the JSON can be very large, and parsing JSON is very
            //  expensive (compared to parsing BSON). So we trust that the file
            //  name is correct and indicates what is contained within the file.
            let filename:FilePath.Component = try $1.get()
            guard
            let id:SymbolGraphPart.ID = .init("\(filename)")
            else
            {
                return
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
                return

            default:
                $0[id.culture, default: []].append(id)
            }
        }

        return .init(location: location, modules: symbols)
    }
}
