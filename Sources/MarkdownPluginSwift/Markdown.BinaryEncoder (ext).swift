import MarkdownABI
import SwiftIDEUtils

extension Markdown.BinaryEncoder {
    subscript<UTF8>(highlight color: Markdown.Bytecode.Context?) -> UTF8?
        where UTF8: Collection<UInt8> {
        get { nil }
        set (value) {
            guard
            let value: UTF8 else {
                return
            }

            if  let color: Markdown.Bytecode.Context {
                self[color] { $0 += value }
            } else {
                self += value
            }
        }
    }
}
