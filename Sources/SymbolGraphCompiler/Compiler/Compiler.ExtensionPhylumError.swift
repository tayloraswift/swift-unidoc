import SymbolResolution

extension Compiler
{
    public
    struct ExtensionPhylumError:Equatable, Error
    {
        public
        let phylum:SymbolPhylum
        public
        let usr:UnifiedSymbolResolution

        public
        init(invalid phylum:SymbolPhylum, usr:UnifiedSymbolResolution)
        {
            self.phylum = phylum
            self.usr = usr
        }
    }
}
extension Compiler.ExtensionPhylumError:CustomStringConvertible
{
    public
    var description:String
    {
        "Extension block '\(self.usr)' has invalid phylum '\(self.phylum)'."
    }
}
