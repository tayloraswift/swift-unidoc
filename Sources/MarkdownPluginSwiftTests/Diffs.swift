import HTML
import MarkdownPluginSwift
import MarkdownRendering
import Testing

@Suite
struct Diffs
{
    @Test
    static func Overlays()
    {
        let swift:Markdown.SwiftLanguage = .swift
        let code:String = """
        {
            return \"""
            Barbieland
            One
            Great
            Free
            \"""
        }
        """

        let bytes:[UInt8] = .init(code.utf8)
        let lines:[ArraySlice<UInt8>] = bytes.split(separator: 0x0A,
            omittingEmptySubsequences: false)

        let layered:Markdown.Bytecode = swift.parse(code: bytes,
            diff: [
                (bytes.startIndex ..< lines[3].startIndex, nil),
                (lines[3].startIndex ..< lines[6].startIndex, .insert),
                (lines[6].startIndex ..< bytes.endIndex, nil)
            ])

        let html:HTML = .init { $0 += layered.safe }

        #expect("\(html)" == """
            {
                <span class='xk'>return</span> <span class='xs'>\"""</span>
                <span class='xs'>Barbieland
            </span><ins>    <span class='xs'>One
            </span>    <span class='xs'>Great
            </span>    <span class='xs'>Free</span>
            </ins>    <span class='xs'>\"""</span>
            }
            """)
    }
}
