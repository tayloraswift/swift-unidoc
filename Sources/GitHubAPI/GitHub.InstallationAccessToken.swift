extension GitHub
{
    @frozen public
    struct InstallationAccessToken:Sendable
    {
        public
        let value:String

        @inlinable public
        init(value:String)
        {
            self.value = value
        }
    }
}
extension GitHub.InstallationAccessToken:ExpressibleByStringLiteral
{
    @inlinable public
    init(stringLiteral:String) { self.init(value: stringLiteral) }
}
extension GitHub.InstallationAccessToken:CustomStringConvertible
{
    @inlinable public
    var description:String { self.value }
}
