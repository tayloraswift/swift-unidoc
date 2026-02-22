import FNV1
import UnidocAPI
import UnidocServer

extension Unidoc.PluginContext {
    func log(uplinked: Unidoc.UplinkStatus) {
        self.log {
            $0[.dl] {
                $0[.dt] = "Edition"
                $0[.dd] = "\(uplinked.edition)"

                $0[.dt] = "Volume"
                $0[.dd] = "\(uplinked.volume)"

                $0[.dt] = "Hidden?"
                $0[.dd] = uplinked.hidden ? "yes" : "no"

                guard
                let delta: Unidoc.SurfaceDelta = uplinked.delta else {
                    return
                }

                $0[.dt] = "Delta"

                let api: Unidoc.SitemapDelta?

                switch delta {
                case .initial:
                    $0[.dd] = "Initial"
                    return

                case .ignoredHistorical:
                    $0[.dd] = "Ignored historical"
                    return

                case .ignoredPrivate:
                    $0[.dd] = "Ignored private"
                    return

                case .ignoredRepeated(let delta):
                    $0[.dd] = "Ignored repeated"
                    api = delta

                case .replaced(let delta):
                    $0[.dd] = "Replaced"
                    api = delta
                }

                guard
                let api: Unidoc.SitemapDelta else {
                    return
                }

                for (list, name): ([Unidoc.Shoot], String) in [
                        (api.deletions, "Deletions"),
                        (api.additions, "Additions")
                    ]   where !list.isEmpty {
                    $0[.dt] = name
                    $0[.dd] {
                        $0[.ol] {
                            for shoot: Unidoc.Shoot in list {
                                if  let hash: FNV24 = shoot.hash {
                                    $0[.li] = "\(shoot.stem) [\(hash)]"
                                } else {
                                    $0[.li] = "\(shoot.stem)"
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    func log(unlinked: Unidoc.UnlinkStatus) {
        self.log {
            $0[.dl] {
                switch unlinked {
                case .declined(let id):
                    $0[.dt] = "Declined"
                    $0[.dd] = "\(id)"

                case .unlinked(let id):
                    $0[.dt] = "Unlinked"
                    $0[.dd] = "\(id)"
                }
            }
        }
    }

    func log(deleted: Unidoc.DeleteStatus) {
        self.log {
            $0[.dl] {
                switch deleted {
                case .declined(let id):
                    $0[.dt] = "Declined"
                    $0[.dd] = "\(id)"

                case .deleted(let id, let fromS3):
                    $0[.dt] = "Deleted"
                    $0[.dd] = "\(id)"

                    $0[.dt] = "From S3?"
                    $0[.dd] = fromS3 ? "yes" : "no"
                }
            }
        }
    }

    func log(failed action: Unidoc.LinkerAction, id: Unidoc.Edition) {
        self.log {
            $0[.dl] {
                $0[.dt] = "Edition"
                $0[.dd] = "\(id)"

                $0[.dt] = "Action"
                $0[.dd] = "\(action)"
            }
        }
    }
}
