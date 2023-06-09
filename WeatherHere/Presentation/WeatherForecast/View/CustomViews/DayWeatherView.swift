//
//  DayWeatherView.swift
//  WeatherHere
//
//  Created by Prashant Pandey on 6/8/23.
//

import UIKit

class DayWeatherView: UIView {

    // MARK: UI Properties
    lazy var weatherIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .systemPink
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false

        return imageView
    }()

    lazy var weatherDescriptionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 25, weight: .semibold)
        label.textColor = .label
        label.text = "--"
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    lazy var locationLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 25)
        label.textColor = .secondaryLabel
        label.text = "--"
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 50, weight: .heavy)
        label.textColor = .label
        label.text = "--°"
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    lazy var contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.alignment = .center
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false

        return stack
    }()

    // MARK: - Activity Indicator
    lazy var activityIndicator = UIActivityIndicatorView(style: .medium)

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
        backgroundColor = .systemBackground
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentStackView)
        [locationLabel, weatherDescriptionLabel, weatherIcon, temperatureLabel].forEach { contentStackView.addArrangedSubview($0) }
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: topAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor)
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

    public func startWeatherIndicator(start: Bool) {
        DispatchQueue.main.async {
            start ? self.activityIndicator.startAnimating() : self.activityIndicator.stopAnimating()
        }
    }
}
