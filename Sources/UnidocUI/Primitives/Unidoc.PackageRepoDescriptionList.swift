import HTML
import UnixCalendar

extension Unidoc {
    struct PackageRepoDescriptionList {
        private let repo: PackageRepo
        private let mode: DisplayMode

        init(repo: Unidoc.PackageRepo, mode: DisplayMode) {
            self.repo = repo
            self.mode = mode
        }
    }
}
extension Unidoc.PackageRepoDescriptionList: HTML.OutputStreamable {
    static func += (dl: inout HTML.ContentEncoder, self: Self) {
        switch self.repo.origin {
        case .github(let origin):
            dl[.dt] = "Registrar"
            dl[.dd] = "GitHub"

            if  let license: Unidoc.PackageLicense = self.repo.license {
                dl[.dt] = "License"
                dl[.dd] = license.name
            }
            if !self.repo.topics.isEmpty {
                dl[.dt] = "Keywords"
                dl[.dd] = self.repo.topics.joined(separator: ", ")
            }

            dl[.dt] = "Owner"
            dl[.dd] {
                if  let account: Unidoc.Account = self.repo.account {
                    $0[.a] {
                        $0.href = "\(Unidoc.UserPropertyEndpoint[account])"
                    } = origin.owner
                } else {
                    $0[.span] = origin.owner
                }

                $0[.span, { $0.class = "parenthetical" }] {
                    $0[.a] {
                        $0.target = "_blank"
                        $0.href = "https://github.com/\(origin.owner)"
                        $0.rel = .external
                    } = "view profile"
                }
            }
        }

        if  case .expanded(let locale) = self.mode {
            dl[.dt] = "Stars"
            dl[.dd] = "\(self.repo.stars)"

            dl[.dt] = "Forks"
            dl[.dd] = "\(self.repo.forks)"

            dl[.dt] = "Archived?"
            dl[.dd] = self.repo.origin.alive ? "no" : "yes"

            guard
            let created: Timestamp.Date = self.repo.created.timestamp?.date else {
                return
            }

            dl[.dt] = "Created"
            dl[.dd] {
                $0[.a] {
                    $0.href = "\(Unidoc.PackagesCreatedEndpoint[created])"
                } = created.long(locale)
            }
        }
    }
}
