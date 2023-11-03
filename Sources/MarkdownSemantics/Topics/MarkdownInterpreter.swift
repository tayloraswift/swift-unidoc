import MarkdownAST

struct MarkdownInterpreter
{
    private
    var topicsHeading:Int?
    private
    var topics:[MarkdownDocumentation.Topic]
    private
    var blocks:[MarkdownBlock]

    init()
    {
        self.topicsHeading = nil
        self.topics = []
        self.blocks = []
    }
}
extension MarkdownInterpreter
{
    mutating
    func append(_ block:__owned MarkdownBlock)
    {
        defer
        {
            self.blocks.append(block)
        }

        //  Only h2 headings are interesting, but if we encounter a stray h1, that can
        //  also terminate a topics list.
        guard case (let heading as MarkdownBlock.Heading) = block, heading.level <= 2
        else
        {
            return
        }

        self.interpret()

        if  heading.level == 2,
            heading.elements.count == 1,
            heading.elements[0].text.lowercased() == "topics"
        {
            self.topicsHeading = self.blocks.endIndex
        }
        else
        {
            self.topicsHeading = nil
        }
    }

    mutating
    func load() -> (article:[MarkdownBlock], topics:[MarkdownDocumentation.Topic])
    {
        defer
        {
            self.topicsHeading = nil
            self.topics = []
            self.blocks = []
        }

        self.interpret()

        return (self.blocks, self.topics)
    }

    private mutating
    func interpret()
    {
        func h3(_ block:MarkdownBlock) -> Bool
        {
            if  case (let heading as MarkdownBlock.Heading) = block, heading.level == 3
            {
                return true
            }
            else
            {
                return false
            }
        }

        guard let start:Int = self.topicsHeading
        else
        {
            return
        }

        var pending:[MarkdownDocumentation.Topic] = []
        var current:Int = self.blocks.index(after: start)
        while current < self.blocks.endIndex
        {
            //  If this is the first iteration, we need to ensure the topics list
            //  began with an h3 heading.
            guard !pending.isEmpty || h3(self.blocks[current])
            else
            {
                return
            }

            if  let next:Int = self.blocks[self.blocks.index(after: current)...].firstIndex(
                    where: h3(_:))
            {
                if  let topic:MarkdownDocumentation.Topic = .init(self.blocks[current ..< next])
                {
                    pending.append(topic)
                    current = next
                    continue
                }
            }
            else if let topic:MarkdownDocumentation.Topic = .init(self.blocks[current...])
            {
                self.topics += pending
                self.topics.append(topic)

                self.blocks[start...] = []
            }

            return
        }
    }
}
