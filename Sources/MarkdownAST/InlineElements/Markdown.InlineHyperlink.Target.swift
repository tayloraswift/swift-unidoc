import Sources

extension Markdown.InlineHyperlink
{
    @frozen public
    enum Target:Sendable
    {
        /// The link target has already been outlined.
        case outlined(Int)

        /// The link target is a fragment within the current document. The string does not
        /// include a leading `#`.
        case urlFragment(Markdown.SourceString)
        case url(Markdown.SourceURL)
    }
}
extension Markdown.InlineHyperlink.Target
{
    @inlinable
    init?(source:SourceReference<Markdown.Source>, target:String)
    {
        switch target[target.startIndex]
        {
        case "#":
            let i:String.Index = target.index(after: target.startIndex)
            self = .urlFragment(.init(source: source, string: String.init(target[i...])))

        case "/":
            self = .url(.init(scheme: nil, suffix: .init(source: source, string: target)))

        case ".":
            let trimmed:Markdown.SourceString
            let i:String.Index = target.index(after: target.startIndex)
            if  i < target.endIndex, target[i] == "/"
            {
                let j:String.Index = target.index(after: i)
                if  j == target.endIndex
                {
                    return nil
                }

                trimmed = .init(source: source, string: String.init(target[j...]))
            }
            else
            {
                trimmed = .init(source: source, string: target)
            }

            self = .url(.init(scheme: nil, suffix: trimmed))

        default:
            self = .url(.init(from: .init(source: source, string: target)))
        }
    }
}
