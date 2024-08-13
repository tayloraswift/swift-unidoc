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
        let resolvableLinks:UCF.ResolutionTable<UCF.CausalOverload>
        public
        let declarations:[(id:Symbol.Module, decls:[Decl])]
        public
        let extensions:[SSGC.Extension]
        public
        let features:[Symbol.Decl: Feature]

        public
        var language:Phylum.Language?
        public
        var markdown:[any SSGC.ResourceFile]
        public
        var resources:[any SSGC.ResourceFile]


        init(id:Symbol.Module,
            resolvableLinks:UCF.ResolutionTable<UCF.CausalOverload>,
            declarations:[(id:Symbol.Module, decls:[Decl])],
            extensions:[SSGC.Extension],
            features:[Symbol.Decl: Feature],
            language:Phylum.Language? = nil,
            markdown:[any SSGC.ResourceFile] = [],
            resources:[any SSGC.ResourceFile] = [])
        {
            self.id = id
            self.resolvableLinks = resolvableLinks
            self.declarations = declarations
            self.extensions = extensions
            self.features = features
            self.language = language
            self.markdown = markdown
            self.resources = resources
        }
    }
}
