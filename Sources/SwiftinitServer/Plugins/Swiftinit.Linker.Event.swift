extension Swiftinit.Linker
{
    enum Event:Sendable
    {
        case uplinked(Unidoc.UplinkStatus)
        case failed(Unidoc.Edition)
        case caught(any Error)
    }
}
