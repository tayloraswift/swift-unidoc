import LinkResolution
import Symbols
import UCF

extension SSGC
{
    @frozen public
    struct ModuleIndex
    {
        public
        let id:Symbol.Module

        public
        let resolvableModules:[Symbol.Module]
        public
        let resolvableLinks:UCF.ResolutionTable<UCF.CausalOverload>
        public
        let declarations:[(id:Symbol.Module, decls:[Decl])]
        public
        let extensions:[SSGC.Extension]
        public
        let reexports:[Symbol.Decl: DeclAlias]
        public
        let features:[Symbol.Decl: DeclAlias]

        public
        var language:Phylum.Language?
        public
        var markdown:[any SSGC.ResourceFile]
        public
        var resources:[any SSGC.ResourceFile]


        init(id:Symbol.Module,
            resolvableModules:[Symbol.Module],
            resolvableLinks:UCF.ResolutionTable<UCF.CausalOverload>,
            declarations:[(id:Symbol.Module, decls:[Decl])],
            extensions:[SSGC.Extension],
            reexports:[Symbol.Decl: DeclAlias],
            features:[Symbol.Decl: DeclAlias],
            language:Phylum.Language? = nil,
            markdown:[any SSGC.ResourceFile] = [],
            resources:[any SSGC.ResourceFile] = [])
        {
            self.id = id
            self.resolvableModules = resolvableModules
            self.resolvableLinks = resolvableLinks
            self.declarations = declarations
            self.extensions = extensions
            self.reexports = reexports
            self.features = features
            self.language = language
            self.markdown = markdown
            self.resources = resources
        }
    }
}
