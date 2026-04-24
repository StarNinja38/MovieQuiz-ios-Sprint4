import Foundation

extension Date {
    var dateTimeString: String { DateFormatter.defaultDateTime.string(from: self) }
}

private extension DateFormatter {
    static let defaultDateTime: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        return dateFormatter
    }()
}
