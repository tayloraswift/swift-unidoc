import SourceDiagnostics
import UCF

extension SSGC {
    struct AnchorResolutionError: Error {
        let id: UCF.AnchorMangling
        let fragment: String
        let scope: Int32?
        let notes: [Note]

        init(id: UCF.AnchorMangling, fragment: String, scope: Int32?, notes: [Note]) {
            self.id = id
            self.fragment = fragment
            self.scope = scope
            self.notes = notes
        }
    }
}
extension SSGC.AnchorResolutionError: Diagnostic {
    typealias Symbolicator = SSGC.Symbolicator

    func emit(summary output: inout DiagnosticOutput<Symbolicator>) {
        if  let scope: Int32 = self.scope {
            output[.error] += """
            link fragment '\(self.fragment)' (\(self.id)) does not match any linkable anchor on
            its target page (\(output.symbolicator[scope]))
            """
        } else {
            output[.error] += """
            link fragment '\(self.fragment)' (\(self.id)) does not match any linkable anchor on
            its target page (unknown extension)
            """
        }
    }

    func emit(details output: inout DiagnosticOutput<Symbolicator>) {
        for note: Note in self.notes {
            output[.note] = """
            available choice '\(note.fragment)' (\(note.id))
            """
        }
    }
}
