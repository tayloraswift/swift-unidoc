import SymbolResolution

public
struct ExtensionBlockPhylumError:Equatable, Error
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
extension ExtensionBlockPhylumError:CustomStringConvertible
{
    public
    var description:String
    {
        "Extension block '\(self.usr)' has invalid phylum '\(self.phylum)'."
    }
}
