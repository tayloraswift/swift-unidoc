import HTML
import SymbolGraphs

extension SymbolGraph.OutlineText: HTML.OutputStreamable {
    /// Writes the ``path`` components only to the output HTML, using `.` as the path separator.
    @inlinable public static func += (code: inout HTML.ContentEncoder, self: Self) {
        for byte: UInt8 in self.path.utf8 {
            code.append(unescaped: byte == 0x20 ? 0x2E : byte)
        }
    }
}
