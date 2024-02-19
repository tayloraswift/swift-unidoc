import MarkdownABI

extension StaticLinker
{
    struct ResourceText
    {
        /// Each line of the resource, as a slice of the whole. The indices of the slices are
        /// indices of the ``whole``.
        private
        var lines:[ArraySlice<UInt8>]
        let whole:[UInt8]

        private
        init(lines:[ArraySlice<UInt8>], whole:[UInt8])
        {
            self.lines = lines
            self.whole = whole
        }
    }
}
extension StaticLinker.ResourceText
{
    init(utf8:[UInt8], trimmingTrailingNewlines:Bool)
    {
        self.init(
            lines: utf8.split(omittingEmptySubsequences: false) { $0 == 0x0A },
            whole: utf8)

        //                           '\t'  '\n'  '\r'   ' '
        let whitespace:Set<UInt8> = [0x09, 0x0A, 0x0D, 0x20]
        if  trimmingTrailingNewlines,
            let i:Int = self.lines.lastIndex(where: { $0.allSatisfy(whitespace.contains(_:)) })
        {
            self.lines[i...] = []
        }
    }

    func diff(from base:Self?) -> [(range:Range<Int>, color:Markdown.DiffType?)]
    {
        base.map(self.diff(from:)) ??  [(self.whole.indices, nil)]
    }

    func diff(from base:Self) -> [(range:Range<Int>, color:Markdown.DiffType?)]
    {
        let difference:CollectionDifference<ArraySlice<UInt8>> = self.lines.difference(
            from: base.lines)

        var layer:[(range:Range<Int>, color:Markdown.DiffType?)] = []
        var start:Int = self.whole.startIndex

        for case .insert(_, let line, _) in difference.insertions
        {
            defer
            {
                start = line.endIndex
            }
            if  start < line.startIndex
            {
                layer.append((start ..< line.startIndex, nil))
            }
            if  line.startIndex < line.endIndex
            {
                layer.append((line.startIndex ..< line.endIndex, .insert))
            }
        }

        if  start < self.whole.endIndex
        {
            layer.append((start ..< self.whole.endIndex, nil))
        }

        return layer
    }
}
