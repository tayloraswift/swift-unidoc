import JSONDecoding

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
extension SymbolDescription.Visibility:CustomStringConvertible
{
    @inlinable public
    var description:String
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
//  Manual conformance needed, because a raw type would inhibit
//  the synthesized ``Comparable`` conformance. And implementing
//  this manually is easier than implementing `<`.
extension SymbolDescription.Visibility:LosslessStringConvertible
{
    @inlinable public
    init?(_ description:String)
    {
        switch description
        {
        case "private":     self = .private
        case "fileprivate": self = .fileprivate
        case "internal":    self = .internal
        case "public":      self = .public
        case "open":        self = .open
        default:            return nil
        }
    }
}
extension SymbolDescription.Visibility:JSONStringDecodable
{
}
