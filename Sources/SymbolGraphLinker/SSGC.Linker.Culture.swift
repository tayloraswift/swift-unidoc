import Symbols

extension SSGC.Linker
{
    struct Culture
    {
        let resources:[String: SSGC.Resource]
        let imports:[Symbol.Module]
        let module:Symbol.Module

        init(resources:[String: SSGC.Resource], imports:[Symbol.Module], module:Symbol.Module)
        {
            self.resources = resources
            self.imports = imports
            self.module = module
        }
    }
}
