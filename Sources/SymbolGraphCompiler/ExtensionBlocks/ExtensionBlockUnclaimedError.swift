import SymbolResolution

public
struct ExtensionBlockUnclaimedError:Equatable, Error
{
    public
    let usr:UnifiedSymbolResolution

    public
    init(usr:UnifiedSymbolResolution)
    {
        self.usr = usr
    }
}
extension ExtensionBlockUnclaimedError:CustomStringConvertible
{
    public
    var description:String
    {
        "Extension block '\(self.usr)' is not claimed by any type in its colony."
    }
}
