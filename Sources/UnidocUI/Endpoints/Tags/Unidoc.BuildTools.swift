import HTML
import Media
import Symbols
import URI

extension Unidoc {
    struct BuildTools {
        let prerelease: BuildFormTool
        let release: BuildFormTool
        let running: [Unidoc.PendingBuild]
        let view: Unidoc.Permissions
        let back: URI
    }
}
extension Unidoc.BuildTools: HTML.OutputStreamable {
    static func += (section: inout HTML.ContentEncoder, self: Self) {
        section[.div, { $0.class = "hstackable" }] {
            for shortcut: Unidoc.BuildFormTool in [self.release, self.prerelease] {
                $0[.form] {
                    $0.enctype = "\(MediaType.application(.x_www_form_urlencoded))"
                    $0.action = "\(Unidoc.Post[.build, confirm: true])"
                    $0.method = "post"
                } = shortcut
            }
        }

        section[.ol, { $0.id = "builds-pending" }] {
            for build: Unidoc.PendingBuild in self.running {
                $0[.li] {
                    let icon: Unicode.Scalar

                    switch build.host.os {
                    case .linux:        icon = "🐧"
                    case .macosx15_0:   icon = "🍎"
                    case .macosx14_0:   icon = "🍏"
                    default:            icon = "?"
                    }

                    if  let assignee: Unidoc.Account = build.assignee,
                        let stage: Unidoc.BuildStage = build.stage {
                        $0[.div] {
                            $0.title = "This build has been assigned to a builder \(assignee)."
                        } = "Started"

                        $0[.div] { $0.class = "os" ; $0.title = "\(build.host)" } = icon
                        $0[.div] { $0.class = "ref" } = build.name.ref

                        let tooltip: String
                        let label: String

                        switch stage {
                        case .initializing:
                            tooltip = "The builder is initializing."
                            label = "Git"

                        case .cloningRepository:
                            tooltip = "The builder is cloning the package’s repository."
                            label = "Git"

                        case .resolvingDependencies:
                            tooltip = "The builder is resolving the package’s dependencies."
                            label = "SwiftPM"

                        case .compilingCode:
                            tooltip = "The builder is compiling the package’s source code."
                            label = "Swift"
                        }

                        $0[.div] { $0.title = tooltip } = label
                    } else {
                        $0[.div] {
                            $0.title = "This build has not yet started."
                        } = "Queued"

                        $0[.div] { $0.class = "os" ; $0.title = "\(build.host)" } = icon
                        $0[.div] { $0.class = "ref" } = build.name.ref
                        $0[.div]
                    }

                    $0[.form] {
                        $0.enctype = "\(MediaType.application(.x_www_form_urlencoded))"
                        $0.action = "\(Unidoc.Post[.build, confirm: true])"
                        $0.method = "post"
                    } = Unidoc.BuildFormTool.control(pending: build, view: self.view)
                }
            }
        }
    }
}
