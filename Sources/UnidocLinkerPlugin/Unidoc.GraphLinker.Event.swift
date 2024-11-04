import FNV1
import HTML
import UnidocAPI
import UnidocServer

extension Unidoc.GraphLinker
{
    @frozen public
    enum Event:Sendable
    {
        case uplinked(Unidoc.UplinkStatus)
        case unlinked(Unidoc.UnlinkStatus)
        case deleted(Unidoc.DeleteStatus)
        case failed(Unidoc.Edition, action:Unidoc.LinkerAction)
    }
}
extension Unidoc.GraphLinker.Event:Unidoc.ServerEvent
{
    public
    func h3(_ h3:inout HTML.ContentEncoder)
    {
        switch self
        {
        case .uplinked: h3 += "Volume uplinked"
        case .unlinked: h3 += "Volume unlinked"
        case .deleted:  h3 += "Volume deleted"
        case .failed:   h3 += "Action failed"
        }
    }

    public
    func dl(_ dl:inout HTML.ContentEncoder)
    {
        switch self
        {
        case .uplinked(let uplinked):
            dl[.dt] = "Edition"
            dl[.dd] = "\(uplinked.edition)"

            dl[.dt] = "Volume"
            dl[.dd] = "\(uplinked.volume)"

            dl[.dt] = "Hidden?"
            dl[.dd] = uplinked.hidden ? "yes" : "no"

            guard
            let delta:Unidoc.SurfaceDelta = uplinked.delta
            else
            {
                return
            }

            dl[.dt] = "Delta"

            let api:Unidoc.SitemapDelta?

            switch delta
            {
            case .initial:
                dl[.dd] = "Initial"
                return

            case .ignoredHistorical:
                dl[.dd] = "Ignored historical"
                return

            case .ignoredPrivate:
                dl[.dd] = "Ignored private"
                return

            case .ignoredRepeated(let delta):
                dl[.dd] = "Ignored repeated"
                api = delta

            case .replaced(let delta):
                dl[.dd] = "Replaced"
                api = delta
            }

            guard
            let api:Unidoc.SitemapDelta
            else
            {
                return
            }

            for (list, name):([Unidoc.Shoot], String) in [
                (api.deletions, "Deletions"),
                (api.additions, "Additions")
            ]   where !list.isEmpty
            {
                dl[.dt] = name
                dl[.dd]
                {
                    $0[.ol]
                    {
                        for shoot:Unidoc.Shoot in list
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
            switch unlinked
            {
            case .unlinked(let edition):
                dl[.dt] = "Unlinked"
                dl[.dd] = "\(edition)"

            case .declined(let edition):
                dl[.dt] = "Declined"
                dl[.dd] = "\(edition)"
            }

        case .deleted(let deleted):
            switch deleted
            {
            case .deleted(let edition, let fromS3):
                dl[.dt] = "Deleted"
                dl[.dd] = "\(edition)"

                dl[.dt] = "From S3?"
                dl[.dd] = fromS3 ? "yes" : "no"

            case .declined(let edition):
                dl[.dt] = "Declined"
                dl[.dd] = "\(edition)"
            }

        case .failed(let edition, action: let action):
            dl[.dt] = "Edition"
            dl[.dd] = "\(edition)"

            dl[.dt] = "Action"
            dl[.dd] = "\(action)"
        }
    }
}
