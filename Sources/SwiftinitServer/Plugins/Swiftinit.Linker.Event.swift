import FNV1
import HTML

extension Swiftinit.Linker
{
    enum Event:Unidoc.CollectionEvent, Sendable
    {
        case uplinked(Unidoc.UplinkStatus)
        case unlinked(Unidoc.UnlinkStatus)
        case deleted(Unidoc.DeleteStatus)
        case failed(Unidoc.Edition, action:Unidoc.Snapshot.PendingAction)
        case caught(any Error)
    }
}
extension Swiftinit.Linker.Event:HTML.OutputStreamable
{
    static
    func += (div:inout HTML.ContentEncoder, self:Self)
    {
        switch self
        {
        case .uplinked(let uplinked):
            div[.h3] = "Uplinked volume"
            div[.dl]
            {
                $0[.dt] = "Edition"
                $0[.dd] = "\(uplinked.edition)"

                $0[.dt] = "Volume"
                $0[.dd] = "\(uplinked.volume)"

                $0[.dt] = "Hidden?"
                $0[.dd] = uplinked.hidden ? "yes" : "no"

                guard
                let delta:Unidoc.SitemapDelta = uplinked.delta
                else
                {
                    return
                }

                $0[.dt] = "Additions"
                $0[.dd] = "\(delta.additions)"

                if  delta.deletions.isEmpty
                {
                    return
                }

                $0[.dt] = "Deletions"
                $0[.dd]
                {
                    $0[.ol]
                    {
                        for shoot:Unidoc.Shoot in delta.deletions
                        {
                            if  let hash:FNV24 = shoot.hash
                            {
                                $0[.li] = "\(shoot.stem) [\(hash)]"
                            }
                            else
                            {
                                $0[.li] = "\(shoot.stem)"
                            }
                        }
                    }
                }
            }

        case .unlinked(let unlinked):
            div[.h3] = "Unlinked volume"
            div[.dl]
            {
                switch unlinked
                {
                case .unlinked(let edition):
                    $0[.dt] = "Unlinked"
                    $0[.dd] = "\(edition)"

                case .declined(let edition):
                    $0[.dt] = "Declined"
                    $0[.dd] = "\(edition)"
                }
            }

        case .deleted(let deleted):
            div[.h3] = "Deleted volume"
            div[.dl]
            {
                switch deleted
                {
                case .deleted(let edition, let fromS3):
                    $0[.dt] = "Deleted"
                    $0[.dd] = "\(edition)"

                    $0[.dt] = "From S3?"
                    $0[.dd] = fromS3 ? "yes" : "no"

                case .declined(let edition):
                    $0[.dt] = "Declined"
                    $0[.dd] = "\(edition)"
                }
            }

        case .failed(let edition, action: let action):
            div[.h3] = "Failed"
            div[.dl]
            {
                $0[.dt] = "Edition"
                $0[.dd] = "\(edition)"

                $0[.dt] = "Action"
                $0[.dd] = "\(action)"
            }

        case .caught(let error):
            div[.h3] = "Caught error"
            div[.pre] = String.init(reflecting: error)
        }
    }
}
