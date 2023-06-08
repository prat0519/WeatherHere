//
//  Extensions.swift
//  WeatherHere
//
//  Created by Prashant Pandey on 6/8/23.
//

import UIKit

// MARK: - Fetch localized Strings
extension String {
    /// Retrieve strings from localized string file
    /// - Returns: localized string
    func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }

    /// Get Day and Time of the week from string date
    func dayofWeek() -> String {
        // Convert to date first
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current

        guard let date = dateFormatter.date(from: self) else { return "" }

        let convertDateFormatter = DateFormatter()
        convertDateFormatter.dateFormat = "MMM dd yyyy h:mm a"

        return convertDateFormatter.string(from: date)
    }
}

extension Double {
    /// Current temperature form service is represented in Kelvin. This is a conversion method
    func convertTemp(to outputTempType: UnitTemperature) -> String {
        let mf = MeasurementFormatter()
        mf.numberFormatter.maximumFractionDigits = 0
        mf.unitOptions = .providedUnit
        let input = Measurement(value: self, unit: UnitTemperature.kelvin)
        let output = input.converted(to: outputTempType)
        return mf.string(from: output)
      }
}

extension UITableViewCell {
    /// Reusable cell identifier
    static var identifier: String {
        return String(describing: self)
    }
}

extension UIView {
    /// Present bottom sheet
    /// - Parameter sheet: BottomSheet of type UIView
    func presentBottomSheet(sheet: UIView) {

        addSubview(sheet)

        NSLayoutConstraint.activate([
            sheet.leadingAnchor.constraint(equalTo: leadingAnchor),
            sheet.trailingAnchor.constraint(equalTo: trailingAnchor),
            sheet.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

extension UIStackView {

    /// Remove arranged subview from a stackview safely
    func safelyRemoveArrangedSubviews() {

        // Remove all the arranged subviews and save them to an array
        let removedSubviews = arrangedSubviews.reduce([]) { (sum, next) -> [UIView] in
            self.removeArrangedSubview(next)
            return sum + [next]
        }

        // Deactive all constraints at once
        NSLayoutConstraint.deactivate(removedSubviews.flatMap({ $0.constraints }))

        // Remove the views from self
        removedSubviews.forEach({ $0.removeFromSuperview() })
    }
}
