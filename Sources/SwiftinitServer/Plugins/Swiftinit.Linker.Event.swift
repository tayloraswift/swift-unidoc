extension Swiftinit.Linker
{
    enum Event:Sendable
    {
        case uplinked(Unidoc.UplinkStatus)
        case unlinked(Unidoc.UnlinkStatus)
        case deleted(Unidoc.DeleteStatus)
        case failed(Unidoc.Edition, action:Unidoc.Snapshot.PendingAction)
        case caught(any Error)
    }
}
