import Sources

extension SourceReference {
    init(trimming trim: Int = 0, from range: Range<_SourceLocation>?, in frame: Frame) {
        if  let range: Range<_SourceLocation>,
            let start: SourcePosition = .init(range.lowerBound, offset: trim),
            let end: SourcePosition = .init(range.upperBound, offset: -trim) {
            self.init(range: start ..< max(start, end), in: frame)
        } else {
            self.init(range: nil, in: frame)
        }
    }
}
