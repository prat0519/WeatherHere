//
//  WeeklyWeatherView.swift
//  WeatherHere
//
//  Created by Prashant Pandey on 6/8/23.
//

import UIKit

class WeeklyWeatherView: UIView {

    // MARK: UI Properties
    lazy var weeklyWeatherTable: UITableView = {
        let table = UITableView()
        table.backgroundColor = .secondarySystemBackground
        table.showsVerticalScrollIndicator = false
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()

    // MARK: - Activity Indicator
    lazy var activityIndicator = UIActivityIndicatorView(style: .medium)

    // MARK: - Details Bottom Sheet
    lazy var detailsBottomSheet = WeatherDetailsView(frame: .zero)

    // MARK: - Data Source
    var dataSource: [DailyWeatherResponse]? {
        didSet {
            setupTableView()
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubViews()
        setupConstraints()
        configureActivityIndicator()
    }

    // MARK: - Private Instance Methods
    private func setupSubViews() {
        backgroundColor = .secondarySystemBackground
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(weeklyWeatherTable)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            weeklyWeatherTable.topAnchor.constraint(equalTo: topAnchor),
            weeklyWeatherTable.bottomAnchor.constraint(equalTo: bottomAnchor),
            weeklyWeatherTable.leadingAnchor.constraint(equalTo: leadingAnchor),
            weeklyWeatherTable.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    private func configureActivityIndicator() {
        activityIndicator.color = .systemGray
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }

    // MARK: - Public Instance Methods
    public func startWeatherIndicator(start: Bool) {
        DispatchQueue.main.async {
            start ? self.activityIndicator.startAnimating() : self.activityIndicator.stopAnimating()
        }
    }
}

// MARK: - Configure Table View
extension WeeklyWeatherView {
    private func setupTableView() {
        DispatchQueue.main.async {
            self.weeklyWeatherTable.register(WeeklyTableCell.self, forCellReuseIdentifier: WeeklyTableCell.identifier)
            self.weeklyWeatherTable.delegate = self
            self.weeklyWeatherTable.dataSource = self
            self.weeklyWeatherTable.reloadData()
        }
    }
}

// MARK: - UITableView Delegate
extension WeeklyWeatherView: UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "Forecast over the next few days"
    }
}

// MARK: - UITableView DataSource
extension WeeklyWeatherView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.dataSource?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: WeeklyTableCell.identifier, for: indexPath) as? WeeklyTableCell,
            let dataSource = dataSource
        else {
            return UITableViewCell()
        }

        cell.configureCell(with: dataSource[indexPath.row])

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let dataSource = dataSource else { return }

        guard
            let condition = dataSource[indexPath.row].weather.first?.description,
            let iconName = dataSource[indexPath.row].weather.first?.main
        else { return }

        let detailsArray = [
            "Expected Condition: \(condition)",
            "Expected Temperature: \(dataSource[indexPath.row].main.temp.convertTemp(to: .fahrenheit))",
            "Expected Max Temperature: \(dataSource[indexPath.row].main.temp_max.convertTemp(to: .fahrenheit))",
            "Expected Min Temperature: \(dataSource[indexPath.row].main.temp_min.convertTemp(to: .fahrenheit))",
            "Expected Humidity: \(dataSource[indexPath.row].main.humidity)",
            "Expected Wind Speed: \(dataSource[indexPath.row].wind.speed)",
            "Expected Visibiility: \(dataSource[indexPath.row].visibility)meters"
        ]

        detailsBottomSheet.weatherDetails = detailsArray
        detailsBottomSheet.weatherIconName = iconName
        self.presentBottomSheet(sheet: detailsBottomSheet)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
}
