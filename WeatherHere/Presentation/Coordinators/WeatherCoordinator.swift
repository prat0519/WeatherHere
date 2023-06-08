//
//  WeatherCoordinator.swift
//  WeatherHere
//
//  Created by Prashant Pandey on 6/8/23.
//

import UIKit

class WeatherCoordinator: Coordinator {

    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    /// Initial coordinator loaded
    func start() {
        let scene = WeatherForecastViewController()
        scene.viewModel = WeatherForecastViewModel(apiClient: WeatherAPIService())
        navigationController.pushViewController(scene, animated: true)
    }
}
