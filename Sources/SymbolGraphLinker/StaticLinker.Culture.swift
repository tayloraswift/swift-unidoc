import Symbols

extension StaticLinker
{
    struct Culture
    {
        let resources:[String: Resource]
        let imports:[Symbol.Module]
        let module:Symbol.Module

        init(resources:[String: Resource], imports:[Symbol.Module], module:Symbol.Module)
        {
            self.resources = resources
            self.imports = imports
            self.module = module
        }
    }
}
