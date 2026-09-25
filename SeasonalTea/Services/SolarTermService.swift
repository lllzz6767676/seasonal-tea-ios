import Foundation

/// Calculates the Sun's apparent ecliptic longitude and finds each 15-degree crossing.
/// The low-precision solar model is accurate enough for day-level seasonal UI dates.
struct SolarTermService {
    private static let names = [
        "立春", "雨水", "惊蛰", "春分", "清明", "谷雨",
        "立夏", "小满", "芒种", "夏至", "小暑", "大暑",
        "立秋", "处暑", "白露", "秋分", "寒露", "霜降",
        "立冬", "小雪", "大雪", "冬至", "小寒", "大寒"
    ]

    private static let chinaTimeZone = TimeZone(identifier: "Asia/Shanghai") ?? .current
    private static let utc = TimeZone(secondsFromGMT: 0)!

    func current(for date: Date) -> SolarTerm {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = Self.chinaTimeZone
        let year = calendar.component(.year, from: date)
        let events = ((year - 1)...(year + 1)).flatMap { events(in: $0) }
            .filter { $0.startDate <= date }
            .sorted { $0.startDate < $1.startDate }

        return events.last ?? SolarTerm(
            name: "立春",
            season: "春",
            startDate: date,
            recommendationContext: Self.context(for: "春")
        )
    }

    private func events(in year: Int) -> [SolarTerm] {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = Self.utc
        let start = calendar.date(from: DateComponents(year: year, month: 1, day: 1))!
        let end = calendar.date(from: DateComponents(year: year + 1, month: 1, day: 1))!
        let startAngle = apparentSolarLongitude(julianDay(for: start))
        let endAngle = apparentSolarLongitude(julianDay(for: end))
        let firstStep = Int(floor(startAngle / 15.0)) + 1
        let lastStep = Int(floor(endAngle / 15.0))

        guard firstStep <= lastStep else { return [] }
        return (firstStep...lastStep).compactMap { step in
            let target = Double(step) * 15.0
            let instant = crossingDate(from: start, to: end, targetLongitude: target)
            let longitudeIndex = (step % 24 + 24) % 24
            let termIndex = (longitudeIndex - 21 + 24) % 24
            let season = Self.season(for: termIndex)
            return SolarTerm(
                name: Self.names[termIndex],
                season: season,
                startDate: instant,
                recommendationContext: Self.context(for: season)
            )
        }
    }

    private func crossingDate(from start: Date, to end: Date, targetLongitude: Double) -> Date {
        var lower = start
        var upper = end
        for _ in 0..<48 {
            let middle = lower.addingTimeInterval(upper.timeIntervalSince(lower) / 2)
            if apparentSolarLongitude(julianDay(for: middle)) < targetLongitude {
                lower = middle
            } else {
                upper = middle
            }
        }
        return lower.addingTimeInterval(upper.timeIntervalSince(lower) / 2)
    }

    private func julianDay(for date: Date) -> Double {
        date.timeIntervalSince1970 / 86_400 + 2_440_587.5
    }

    private func apparentSolarLongitude(_ julianDay: Double) -> Double {
        let t = (julianDay - 2_451_545.0) / 36_525.0
        let meanLongitude = 280.46646 + 36_000.76983 * t + 0.0003032 * t * t
        let meanAnomaly = normalizedDegrees(357.52911 + 35_999.05029 * t - 0.0001537 * t * t)
        let anomalyRadians = meanAnomaly * .pi / 180
        let equationOfCenter = (1.914602 - 0.004817 * t - 0.000014 * t * t) * sin(anomalyRadians)
            + (0.019993 - 0.000101 * t) * sin(2 * anomalyRadians)
            + 0.000289 * sin(3 * anomalyRadians)
        let omega = (125.04 - 1_934.136 * t) * .pi / 180
        return meanLongitude + equationOfCenter - 0.00569 - 0.00478 * sin(omega)
    }

    private func normalizedDegrees(_ value: Double) -> Double {
        let remainder = value.truncatingRemainder(dividingBy: 360)
        return remainder < 0 ? remainder + 360 : remainder
    }

    private static func season(for index: Int) -> String {
        switch index {
        case 0...5: return "春"
        case 6...11: return "夏"
        case 12...17: return "秋"
        default: return "冬"
        }
    }

    private static func context(for season: String) -> String {
        switch season {
        case "春": return "春季饮品可以从清爽、少糖的日常选择入手。本推荐只参考季节与饮用场景。"
        case "夏": return "气温渐高，可考虑清爽或常温、少糖的饮品；冷泡需注意卫生并全程冷藏。"
        case "秋": return "天气转凉时，可选择温热或常温饮品，按口味调整；饮用体验不代表治疗作用。"
        default: return "天气偏冷时，温热饮品可能更符合口味偏好；热饮体验不代表“驱寒”或治疗作用。"
        }
    }
}
