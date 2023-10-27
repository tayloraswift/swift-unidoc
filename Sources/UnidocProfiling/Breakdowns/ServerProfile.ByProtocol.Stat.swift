import HTML

extension ServerProfile.ByProtocol
{
    @usableFromInline internal
    struct Stat:Identifiable, Sendable
    {
        @usableFromInline internal
        let id:String

        let stratum:String

        @usableFromInline internal
        let value:Int

        @usableFromInline internal
        let `class`:String?

        init(_ id:String, stratum:String, value:Int, `class`:String? = nil)
        {
            self.id = id
            self.stratum = stratum
            self.value = value
            self.class = `class`
        }
    }
}
extension ServerProfile.ByProtocol.Stat:PieSector
{
    @usableFromInline internal
    func label(share:Double) -> String
    {
        """
        \(Self.format(share: share)) percent of the \
        \(self.stratum) during this tour were using \(self.id)
        """
    }
}
