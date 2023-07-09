@frozen public
enum MarkdownRenderingError:Error, Equatable, Sendable
{
    /// A renderer executed an illegal instruction, such as
    /// returning from an empty element context stack.
    case illegalInstruction
    /// A renderer encountered an invalid instruction.
    case invalidInstruction
    /// A renderer finished executing markdown bytecode
    /// without returning from all open element contexts.
    case interrupted
}
