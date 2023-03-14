/// Line 1
/// Line 2 (ending in space) 
///  Line 3 (prefixed with space)
public
enum Doccomments
{
    ///     Line 1 (indented)
    ///         Line 2 (indented twice)
    ///  Line 3 (not indented)
    case a
    ///
    /// 
    /// Line 1 (two empty lines before)
    case b
    ///       
    /// Line 1 (whitespace-only line before)
    case c
    /** Line 1
        Line 2
        Line 3 (ending in space) 
         Line 4 (prefixed with space)
    */
    case d
    /// Mixed comment block types
    /** Mixed comment block types */
    case e
    /**
        ```
        code
            code
                code
        ```
    */
    case f
    /// special characters
    /// leading backslash \n
    /// unicode 🇺🇸
    case g
    /** nested comment blocks 
        /**
        */
    */
    case h
}
