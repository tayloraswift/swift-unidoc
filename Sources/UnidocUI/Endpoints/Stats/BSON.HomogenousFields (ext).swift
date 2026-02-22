import BSON
import PieCharts
import UnidocRecords

extension BSON.HomogenousFields: Pie.ChartSource where Key: Pie.ChartKey, Value == Int {
    public var sectors: [(key: Key, value: Int)] { self.ordered }
}
