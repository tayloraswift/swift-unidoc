import SymbolGraphs
import Symbols

extension Unidoc {
    struct ModuleDemonym {
        let language: Phylum.Language
        let type: SymbolGraph.ModuleType

        init(language: Phylum.Language, type: SymbolGraph.ModuleType) {
            self.language = language
            self.type = type
        }
    }
}
extension Unidoc.ModuleDemonym {
    var title: String {
        switch (self.language, self.type) {
        case (_, .binary):      "Binary Module"
        case (_, .executable):  "Executable"
        case (.c, .regular):    "Library Module (C)"
        case (.cpp, .regular):  "Library Module (C++)"
        case (_, .regular):     "Library Module"
        case (_, .macro):       "Macro Module"
        case (_, .plugin):      "Plugin Module"
        case (_, .snippet):     "Snippet"
        case (_, .system):      "System Module"
        case (_, .test):        "Test Module"
        case (_, .book):        "Book"
        }
    }

    var phrase: String {
        switch (self.language, self.type) {
        case (_, .binary):      "a binary module"
        case (_, .executable):  "an executable target"
        case (.c, .regular):    "a C module"
        case (.cpp, .regular):  "a C++ module"
        case (_, .regular):     "a library module"
        case (_, .macro):       "a macro target"
        case (_, .plugin):      "a plugin target"
        case (_, .snippet):     "a snippet"
        case (_, .system):      "a system module"
        case (_, .test):        "a test module"
        case (_, .book):        "a book"
        }
    }
}
