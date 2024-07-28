import Symbols

extension SSGC
{
    @frozen public
    struct Declarations:Sendable
    {
        public
        let namespaces:[(id:Symbol.Module, decls:[Decl])]
        public
        let language:Phylum.Language
        public
        let culture:Symbol.Module

        init(namespaces:[(id:Symbol.Module, decls:[Decl])],
            language:Phylum.Language,
            culture:Symbol.Module)
        {
            self.namespaces = namespaces
            self.language = language
            self.culture = culture
        }
    }
}
