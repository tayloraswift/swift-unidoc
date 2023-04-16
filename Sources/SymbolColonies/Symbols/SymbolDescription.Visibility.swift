import JSONDecoding
import JSONEncoding

extension SymbolDescription
{
    @frozen public
    enum Visibility:Hashable, Comparable, Sendable
    {
        case `private`
        case `fileprivate`
        case `internal`
        case `public`
        case open
    }
}
//  Manual conformance needed, because a raw type would inhibit
//  the synthesized ``Comparable`` conformance. And implementing
//  this manually is easier than implementing `<`.
extension SymbolDescription.Visibility:RawRepresentable
{
    @inlinable public
    init?(rawValue:String)
    {
        switch rawValue
        {
        case "private":     self = .private
        case "fileprivate": self = .fileprivate
        case "internal":    self = .internal
        case "public":      self = .public
        case "open":        self = .open
        default:            return nil
        }
    }
    @inlinable public
    var rawValue:String
    {
        switch self
        {
        case .private:      return "private"
        case .fileprivate:  return "fileprivate"
        case .internal:     return "internal"
        case .public:       return "public"
        case .open:         return "open"
        }
    }
}
extension SymbolDescription.Visibility:JSONDecodable, JSONEncodable
{
}
