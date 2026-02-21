import SwiftSyntax

extension SnippetParser {
    /// A `SliceBounds` is the precursor to a ``Slice``. It describes the vertical dimensions of
    /// a snippet slice, and the indentation of its first marker statement.
    struct SliceBounds {
        let id: String

        var marker: (line: Int, indent: Int)?
        var ranges: [Range<AbsolutePosition>]

        init(id: String, marker: (line: Int, indent: Int)?) {
            self.id = id
            self.marker = marker
            self.ranges = []
        }
    }
}
extension SnippetParser.SliceBounds {
    func viewbox(in utf8: [UInt8]) -> SnippetParser.Slice? {
        //  We need to do two passes over the source ranges, as indentation is computed across
        //  the entire slice, and not just one subslice.
        var trimEmptyLines: Bool = true
        let ranges: [Range<Int>] = self.ranges.compactMap {
            var start: Int = $0.lowerBound.utf8Offset
            if  start >= utf8.endIndex {
                //  This could happen if the file ends with a control comment and no
                //  final newline.
                return nil
            }

            //  We need to roll forward through any whitespace-only lines. This is difficult
            //  to do at the syntax level, because we traditionally associate trailing trivia
            //  with the token that comes after the slice markers. So we do it here.
            //
            //  This should only be done for the first range, to preserve the ability to insert
            //  empty lines between subslices.
            if  trimEmptyLines {
                trimming:
                while true {
                    for (i, byte): (Int, UInt8) in zip(start..., utf8[start...]) {
                        switch byte {
                        //  '\r', '\t', ' '
                        case 0x0D, 0x09, 0x20:
                            continue

                        //  '\n'
                        case 0x0A:
                            start = utf8.index(after: i)
                            continue trimming

                        default:
                            break trimming
                        }
                    }
                }
            }

            let end: Int = min($0.upperBound.utf8Offset, utf8.endIndex)
            if  end <= start {
                //  Also possible due to missing final newlines.
                return nil
            } else {
                trimEmptyLines = false
                return start ..< end
            }
        }

        //  Compute maximum removable indentation.
        var indent: Int = self.marker?.indent ?? 0
        for range: Range<Int> in ranges {
            /// We initialize this to 0 and not nil because we assume the range starts at the
            /// beginning of a line.
            var spaces: Int? = 0
            for byte: UInt8 in utf8[range] {
                switch (byte, spaces) {
                //  '\n'
                case    (0x0A, _):
                    spaces = 0

                //  '\r'
                case    (0x0D, _):
                    continue

                //  '\t', ' '
                //  Tabs and spaces both count as one space. This will work correctly as long as
                //  people are not mixing tabs and spaces, which no one should be doing anyway.
                case    (0x09, let count?),
                    (0x20, let count?):
                    spaces = count + 1

                case    (_,    let count?):
                    indent = min(indent, count)
                    spaces = nil

                case    (_,    nil):
                    continue
                }
            }
        }

        var slice: SnippetParser.Slice

        if  indent == 0 {
            slice = .init(id: self.id, line: self.marker?.line ?? 0, ranges: ranges)
        } else {
            slice = .init(id: self.id, line: self.marker?.line ?? 0, ranges: [])
            slice.ranges.reserveCapacity(ranges.count)

            for range: Range<Int> in ranges {
                slice.ranges.append(range)

                var start: Int? = range.lowerBound
                for j: Int in range {
                    switch (utf8[j], start) {
                    //  '\n'
                    case    (0x0A, _):
                        start = j + 1

                    //  '\r'
                    //  '\t', ' '
                    case    (0x0D, _),
                        (0x09, _),
                        (0x20, _):
                        continue

                    case    (_, let i?):
                        slice.punch(hole: (i ..< j).prefix(indent))
                        start = nil

                    case    (_, nil):
                        continue
                    }
                }
            }
        }

        return slice.normalized()
    }
}
