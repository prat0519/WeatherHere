//
//  SearchLocationResultViewController.swift
//  WeatherHere
//
//  Created by Prashant Pandey on 6/8/23.
//

import UIKit
import Combine

protocol SearchLocationsResultsViewModelable: AnyObject {
    var numberOfResults: Int { get }
    var updateResultsPublisher: AnyPublisher<Void, Never> { get }
    var locationSelectionSubject: PassthroughSubject<IndexPath, Never> { get }
    var clearResultsSubject: PassthroughSubject<Void, Never> { get }
    func titleForLocation(at indexPath: IndexPath) -> String
    func updateResults(with cities: [City])
}

class SearchLocationResultViewController: UIViewController {
    typealias ViewModel = SearchLocationsResultsViewModelable
    
    //MARK: Properties
    var viewModel: ViewModel! {
        didSet {
            viewModel.updateResultsPublisher
                .sink { [weak self] in
                    self?.locationsTableView.reloadData()
                }
                .store(in: &cancellables)
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    //MARK: - Views
    
    private lazy var locationsTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "LocationCell")
        return tableView
    }()
    
    //MARK: - View Controller Lyfecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.constraintViews()

    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.clearResultsSubject.send()
    }
    
    //MARK: - Methods
    
    private func setupViews() {
        locationsTableView.dataSource = self
        locationsTableView.delegate = self
        locationsTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(locationsTableView)
    }
    
    private func constraintViews() {
        NSLayoutConstraint.activate([
            locationsTableView.topAnchor.constraint(equalTo: view.topAnchor),
            locationsTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            locationsTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            locationsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

//MARK: - UITableViewDataSource & UITableViewDelegate

extension SearchLocationResultViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel != nil ? viewModel.numberOfResults : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath)
        
        var configuration = cell.defaultContentConfiguration()
        configuration.text = viewModel.titleForLocation(at: indexPath)
        cell.contentConfiguration = configuration
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.locationSelectionSubject.send(indexPath)
        self.dismiss(animated: true)
    }
}
