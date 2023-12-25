import ISO

extension ISO.Macrolanguage:Identifiable
{
    @inlinable public
    var id:String { "\(self)" }
}
extension ISO.Macrolanguage:PieSectorKey
{
    @inlinable public
    var name:String { "\(self)" }
}
