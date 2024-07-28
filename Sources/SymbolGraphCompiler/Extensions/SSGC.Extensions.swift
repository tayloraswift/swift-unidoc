import Symbols

extension SSGC
{
    @frozen public
    struct Extensions
    {
        public
        let compiled:[SSGC.Extension]
        public
        let features:[Symbol.Decl: Feature]
        public
        let culture:Symbol.Module

        init(compiled:[SSGC.Extension], features:[Symbol.Decl: Feature], culture:Symbol.Module)
        {
            self.compiled = compiled
            self.features = features
            self.culture = culture
        }
    }
}
