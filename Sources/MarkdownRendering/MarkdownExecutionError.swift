@frozen public
enum MarkdownExecutionError:Error, Equatable, Sendable
{
    /// A renderer encountered an invalid instruction.
    case invalid
    /// A renderer executed an illegal instruction, such as
    /// returning from an empty element context stack.
    case illegal
    /// A renderer finished executing markdown bytecode
    /// without returning from all open element contexts.
    case incomplete
}
