extension GitHub
{
    @frozen public
    struct PersonalAccessToken:Sendable
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
extension GitHub.PersonalAccessToken:ExpressibleByStringLiteral
{
    @inlinable public
    init(stringLiteral:String) { self.init(value: stringLiteral) }
}
extension GitHub.PersonalAccessToken:CustomStringConvertible
{
    @inlinable public
    var description:String { self.value }
}
