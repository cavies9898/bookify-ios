import Foundation

enum BookifyFormat {
    static func dateTime(_ iso: String) -> String {
        guard let date = parseISO(iso) else { return iso }
        return date.formatted(makeStyle(date: .abbreviated, time: .shortened))
    }

    static func time(_ iso: String) -> String {
        guard let date = parseISO(iso) else { return iso }
        return date.formatted(makeStyle(date: .omitted, time: .shortened))
    }

    static func dateRange(start: String, end: String) -> String {
        "\(dateTime(start)) - \(time(end))"
    }

    static func queryDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    static func price(_ value: Double) -> String {
        String(format: "MXN %.2f", value)
    }

    static func minutes(_ value: Int) -> String {
        "\(value) min"
    }

    static func people(_ value: Int) -> String {
        "\(value) personas"
    }

    static func timeRange(opening: String?, closing: String?) -> String? {
        guard let opening, let closing else { return nil }
        return "\(padTime(opening)) - \(padTime(closing))"
    }

    private static func padTime(_ value: String) -> String {
        let parts = value.split(separator: ":").map(String.init)
        guard parts.count == 2, let hour = Int(parts[0]), let minute = Int(parts[1]) else { return value }
        return String(format: "%02d:%02d", hour, minute)
    }

    private static func makeStyle(
        date: Date.FormatStyle.DateStyle,
        time: Date.FormatStyle.TimeStyle
    ) -> Date.FormatStyle {
        var style = Date.FormatStyle(date: date, time: time)
        style.locale = Locale(identifier: "es")
        return style
    }

    private static func parseISO(_ value: String) -> Date? {
        let fractional = ISO8601DateFormatter()
        fractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = fractional.date(from: value) { return date }
        let plain = ISO8601DateFormatter()
        plain.formatOptions = [.withInternetDateTime]
        if let date = plain.date(from: value) { return date }
        return nil
    }
}
