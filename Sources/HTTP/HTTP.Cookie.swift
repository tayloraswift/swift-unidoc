@available(*, deprecated, renamed: "HTTP.Cookie")
public
typealias Cookie = HTTP.Cookie

extension HTTP
{
    @frozen public
    struct Cookie:Equatable, Hashable, Sendable
    {
        public
        let name:String
        public
        let value:String

        @inlinable public
        init(name:String = "", value:String)
        {
            self.name = name
            self.value = value
        }
    }
}
extension HTTP.Cookie:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        "\(self.name)=\(self.value)"
    }
}
