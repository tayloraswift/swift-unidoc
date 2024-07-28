import Symbols

extension SSGC.Linker
{
    @_spi(testable) public
    struct Culture
    {
        let resources:[String: SSGC.Resource]
        let imports:[Symbol.Module]
        let id:Symbol.Module

        @_spi(testable) public
        init(resources:[String: SSGC.Resource], imports:[Symbol.Module], id:Symbol.Module)
        {
            self.resources = resources
            self.imports = imports
            self.id = id
        }
    }
}
