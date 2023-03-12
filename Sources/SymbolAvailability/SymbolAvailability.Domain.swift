extension SymbolAvailability
{
    @frozen public
    struct Domain<Unavailable, Deprecated, VersionMask>
    {
        public
        let unavailable:Unavailable?
        public
        let deprecated:Deprecated?
        public 
        let introduced:VersionMask?
        public 
        let obsoleted:VersionMask?
        public 
        let renamed:String?
        public 
        let message:String?

        @inlinable public
        init(unavailable:Unavailable? = nil,
            deprecated:Deprecated? = nil,
            introduced:VersionMask? = nil,
            obsoleted:VersionMask? = nil,
            renamed:String? = nil,
            message:String? = nil)
        {
            self.unavailable = unavailable
            self.deprecated = deprecated
            self.introduced = introduced
            self.obsoleted = obsoleted
            self.renamed = renamed
            self.message = message
        }
    }
}
extension SymbolAvailability.Domain:Sendable
    where   Unavailable:Sendable,
            Deprecated:Sendable,
            VersionMask:Sendable
{
}
extension SymbolAvailability.Domain:Equatable
    where   Unavailable:Equatable,
            Deprecated:Equatable,
            VersionMask:Equatable
{
}
extension SymbolAvailability.Domain:Hashable
    where   Unavailable:Hashable,
            Deprecated:Hashable,
            VersionMask:Hashable
{
}
extension SymbolAvailability.Domain
{
    @inlinable public
    var isGenerallyUsable:Bool
    {
        if  case nil = self.unavailable,
            case nil = self.deprecated,
            case nil = self.obsoleted
        {
            return true
        }
        else
        {
            return false
        }
    }
}
