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
        case fragment(Markdown.SourceString)
        /// The link target is an absolute path. The string includes a leading `/`.
        case absolute(Markdown.SourceString)
        /// The link target is a relative path. The string does not include a leading `./`.
        case relative(Markdown.SourceString)
        /// The link target is an external URL. The string does not include the scheme, nor the
        /// delimiting colon.
        case external(Markdown.ExternalURL)
    }
}
extension Markdown.InlineHyperlink.Target
{
    @inlinable
    init?(source:SourceReference<Markdown.Source>, target:String)
    {
        switch target[target.startIndex]
        {
        case "/":
            self = .absolute(.init(source: source, string: target))

        case "#":
            let i:String.Index = target.index(after: target.startIndex)
            self = .fragment(.init(source: source, string: String.init(target[i...])))

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

            self = .relative(trimmed)

        default:
            let link:Markdown.SourceString = .init(source: source, string: target)
            if  let url:Markdown.ExternalURL = .init(from: link)
            {
                self = .external(url)
            }
            else
            {
                self = .relative(link)
            }
        }
    }
}
