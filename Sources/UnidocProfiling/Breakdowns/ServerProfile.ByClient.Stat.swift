import HTML

extension ServerProfile.ByClient
{
    @usableFromInline internal
    struct Stat:Sendable
    {
        @usableFromInline internal
        let name:String

        let stratum:String

        @usableFromInline internal
        let value:Int

        @usableFromInline internal
        let `class`:String?

        init(_ name:String, stratum:String, value:Int, `class`:String? = nil)
        {
            self.name = name
            self.stratum = stratum
            self.value = value
            self.class = `class`
        }
    }
}
extension ServerProfile.ByClient.Stat:Identifiable
{
    @inlinable internal
    var id:String { self.name }
}
extension ServerProfile.ByClient.Stat:PieSector
{
    @usableFromInline internal
    func label(share:Double) -> String
    {
        """
        \(Self.format(share: share)) percent of the \
        \(self.stratum) during this tour were to \(self.name)
        """
    }
}
