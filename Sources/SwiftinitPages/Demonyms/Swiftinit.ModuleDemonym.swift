import SymbolGraphs

extension Swiftinit
{
    struct ModuleDemonym
    {
        let language:SymbolGraph.ModuleLanguage
        let type:SymbolGraph.ModuleType

        init(language:SymbolGraph.ModuleLanguage, type:SymbolGraph.ModuleType)
        {
            self.language = language
            self.type = type
        }
    }
}
extension Swiftinit.ModuleDemonym
{
    var title:String
    {
        switch (self.language, self.type)
        {
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
        }
    }

    var phrase:String
    {
        switch (self.language, self.type)
        {
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
        }
    }
}
