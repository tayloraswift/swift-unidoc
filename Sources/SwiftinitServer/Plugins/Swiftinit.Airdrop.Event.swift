import HTML

extension Swiftinit.Airdrop
{
    enum Event
    {
        case airdropped(to:Int)
        case caught(any Error)
    }
}
extension Swiftinit.Airdrop.Event:Unidoc.CollectionEvent
{
}
extension Swiftinit.Airdrop.Event:HTML.OutputStreamable
{
    static
    func += (div:inout HTML.ContentEncoder, self:Self)
    {
        switch self
        {
        case .airdropped(let users):
            div[.h3] = "Airdropped"
            div[.p] = "Airdropped to \(users) users."

        case .caught(let error):
            div[.h3] = "Caught error"
            div[.pre] = String.init(reflecting: error)
        }
    }
}
