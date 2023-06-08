//
//  WeatherDetailsView.swift
//  WeatherHere
//
//  Created by Prashant Pandey on 6/8/23.
//

import UIKit

class WeatherDetailsView: UIView {

    // MARK: - Data Source
    var weatherDetails: [String]? {
        didSet {
            configureWeatherDetails()
        }
    }

    var weatherIconName: MainEnum? {
        didSet {
            configureIcon()
        }
    }

    // MARK: UI Properties
    lazy var weatherIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .systemPink
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false

        return imageView
    }()

    lazy var contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.alignment = .leading
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        stack.spacing = 3
        stack.translatesAutoresizingMaskIntoConstraints = false

        return stack
    }()

    lazy var closeBtn: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setBackgroundImage(UIImage(named: "xmark.circle.fill"), for: .normal)
        button.addTarget(self, action: #selector(dismiss), for: .touchUpInside)

        return button
    }()

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubViews()
        setupConstraints()
    }

    @objc fileprivate func dismiss() {
        self.removeFromSuperview()
    }

    // MARK: - Private Instance Methods
    private func setupSubViews() {
        self.backgroundColor = .systemGray2
        self.translatesAutoresizingMaskIntoConstraints = false
        self.layer.cornerRadius = 20
        self.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]

        [weatherIcon, closeBtn, contentStackView].forEach { addSubview($0) }
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            closeBtn.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            closeBtn.topAnchor.constraint(equalTo: topAnchor, constant: 10),

            weatherIcon.centerXAnchor.constraint(equalTo: centerXAnchor),
            weatherIcon.topAnchor.constraint(equalTo: topAnchor, constant: 30),

            contentStackView.topAnchor.constraint(equalTo: weatherIcon.bottomAnchor, constant: 10),
            contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30),
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
        ])
    }

    private func configureIcon() {
        guard let icon = weatherIconName else { return }

        let largeFont = UIFont.systemFont(ofSize: 40)
        let configuration = UIImage.SymbolConfiguration(font: largeFont)

        switch icon {
        case .clear:
            self.weatherIcon.image = UIImage(systemName: "sun.max.fill", withConfiguration: configuration)
        case .clouds:
            self.weatherIcon.image = UIImage(systemName: "cloud.fill", withConfiguration: configuration)
        case .rain:
            self.weatherIcon.image = UIImage(systemName: "cloud.drizzle.fill", withConfiguration: configuration)
        case .haze:
            self.weatherIcon.image = UIImage(systemName: "sun.haze.circle.fill", withConfiguration: configuration)
        }
    }

    private func configureWeatherDetails() {
        guard let details = weatherDetails else { return }

        contentStackView.safelyRemoveArrangedSubviews()

        details.forEach {
            let detailLabel: UILabel = {
                let lbl = UILabel()
                lbl.textAlignment = .left
                lbl.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
                lbl.translatesAutoresizingMaskIntoConstraints = false

                return lbl
            }()

            detailLabel.text = $0
            contentStackView.addArrangedSubview(detailLabel)
        }
    }
}
