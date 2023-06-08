//
//  WeeklyTableCell.swift
//  WeatherHere
//
//  Created by Prashant Pandey on 6/8/23.
//

import UIKit

class WeeklyTableCell: UITableViewCell {

    // MARK: - UI Properties
    lazy var dayLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .systemPink
        label.text = "--"
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        label.text = "--"
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .secondaryLabel
        label.text = "--"
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()


    lazy var humidityLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .secondaryLabel
        label.text = "--"
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    lazy var tempStackView: UIStackView = {
        let stack = UIStackView()
        stack.alignment = .leading
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false

        return stack
    }()

    lazy var conditionsStackView: UIStackView = {
        let stack = UIStackView()
        stack.alignment = .trailing
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 5
        stack.translatesAutoresizingMaskIntoConstraints = false

        return stack
    }()

    lazy var contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.alignment = .center
        stack.axis = .horizontal
        stack.distribution = .fillProportionally
        stack.spacing = 5
        stack.translatesAutoresizingMaskIntoConstraints = false

        return stack
    }()

    // MARK: - Initialize Weekly Weather TableView Cell and set constraints
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    // MARK: - Setup table view cell properties
    private func setup() {

        addSubview(contentStackView)
        
        self.accessoryType = .disclosureIndicator
        self.selectionStyle = .none

        [dayLabel, descriptionLabel].forEach { tempStackView.addArrangedSubview($0) }
        [temperatureLabel, humidityLabel].forEach { conditionsStackView.addArrangedSubview($0) }
        [tempStackView, conditionsStackView].forEach { contentStackView.addArrangedSubview($0) }

        NSLayoutConstraint.activate([
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40),
            contentStackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    /// Set details on cell
    /// - Parameter model: WeatherDataItems to be displayed
    public func configureCell(with model: DailyWeatherResponse) {
        dayLabel.text = model.dt_txt.dayofWeek()
        descriptionLabel.text = model.weather.first?.description
        temperatureLabel.text = model.main.temp.convertTemp(to: .fahrenheit)
        humidityLabel.text = "Max: \(model.main.temp_max.convertTemp(to: .fahrenheit))"
    }

    // MARK: - Create initialiser that will be called if an instance of our custom view cell is used
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
