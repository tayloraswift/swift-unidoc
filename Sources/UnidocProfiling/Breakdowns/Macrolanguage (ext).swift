import Media

extension Macrolanguage:Identifiable
{
    @inlinable public
    var id:String { "\(self)" }
}
extension Macrolanguage:PieSectorKey
{
    @inlinable public
    var name:String { "\(self)" }
}
