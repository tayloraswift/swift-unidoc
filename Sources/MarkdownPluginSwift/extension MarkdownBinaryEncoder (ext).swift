import MarkdownABI
import SwiftIDEUtils

extension MarkdownBinaryEncoder
{
    subscript<UTF8>(highlight classification:SyntaxClassification) -> UTF8?
        where UTF8:Collection<UInt8>
    {
        get { nil }
        set (value)
        {
            guard
            let value:UTF8
            else
            {
                return
            }

            if  let context:MarkdownBytecode.Context = .init(classification: classification)
            {
                self[context] { $0 += value }
            }
            else
            {
                self += value
            }
        }
    }
}
