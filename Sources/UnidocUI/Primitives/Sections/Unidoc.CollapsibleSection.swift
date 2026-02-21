import HTML

extension Unidoc {
    struct CollapsibleSection<Content>
        where Content: Unidoc.CollapsibleContent, Content: HTML.OutputStreamable {
        let heading: AutomaticHeading
        let content: Content
        private let open: Bool?

        private init(heading: AutomaticHeading, content: Content, open: Bool?) {
            self.heading = heading
            self.content = content
            self.open = open
        }
    }
}
extension Unidoc.CollapsibleSection {
    init(
        heading: AutomaticHeading,
        content: Content,
        window: ClosedRange<Int>? = nil
    ) {
        guard
        let window: ClosedRange<Int> = window else {
            self.init(heading: heading, content: content, open: nil)
            return
        }

        let visible: Int = content.length
        if  visible < window.lowerBound {
            self.init(heading: heading, content: content, open: nil)
        } else {
            self.init(heading: heading, content: content, open: visible <= window.upperBound)
        }
    }
}
extension Unidoc.CollapsibleSection: HTML.OutputStreamable {
    static func += (section: inout HTML.ContentEncoder, self: Self) {
        section[.h2] = self.heading

        guard
        let open: Bool = self.open else {
            section += self.content
            return
        }

        section[.details, { $0.open = open }] {
            $0[.summary] {
                $0[.p] { $0.class = "view" } = "View members"

                $0[.p] { $0.class = "hide" } = "Hide members"

                $0[.p, { $0.class = "reason" }] {
                    $0 += "This section is hidden by default because it contains too many "

                    $0[.span] { $0.class = "count" } = "(\(self.content.count))"

                    $0 += " members."
                }
            }

            $0 += self.content
        }
    }
}
