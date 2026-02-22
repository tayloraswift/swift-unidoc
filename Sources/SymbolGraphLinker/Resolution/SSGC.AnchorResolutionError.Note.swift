import UCF

extension SSGC.AnchorResolutionError {
    struct Note {
        let id: UCF.AnchorMangling
        let fragment: String

        init(id: UCF.AnchorMangling, fragment: String) {
            self.id = id
            self.fragment = fragment
        }
    }
}
