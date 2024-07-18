//
//  AllTasksViewController.swift
//  TodoList
//
//  Created by Jayant Karthic on 16/07/24.
//


import UIKit
import Combine
import CoreLocation

class AllTasksViewController: BaseViewController {
    private let locationManager = CLLocationManager()
    private let tableView = UITableView()
    var viewModel: AllTasksViewModel?
   // private var weatherService = WeatherService()
    
    private let weatherBar = UIView()
    private let weatherLabel = UILabel()
    private let searchBar = UISearchBar()
    @Published var locationName: String = "Unknown Location"
    override func viewDidLoad() {
        super.viewDidLoad()
        networkMonitor()
       
        setupUI()
        loadTasks()
        locationSetup()
        bindViewModel()
        bindWeatherService()
        setupTapGesture()
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        if viewModel?.isLoading == true{
            showHUD()
        }else{
                self.hideHUD()
            }
    }
    
    func locationSetup(){
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    // function to check for Internet connectivity
    func networkMonitor(){
        
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied{
                print("connected")
            }
            else{
                print("Not connected")
                DispatchQueue.main.async {
                    self.showAlert(message: "Internet connection lost")
                }
                
            }
        }
        
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }
    
    // function to show alert
    func showAlert(message: String){
        let avc = UIAlertController(title: "Info", message: "\(message)", preferredStyle: .alert)
        avc.addAction(UIAlertAction(title: "Ok", style: .default))
        var rootViewController = UIApplication.shared.keyWindow?.rootViewController
        if let navigationController = rootViewController as? UINavigationController{
            rootViewController = navigationController.viewControllers.first
        }
        if let tabBarController = rootViewController as? UITabBarController{
            rootViewController = tabBarController.selectedViewController
        }
        rootViewController?.present(avc, animated: true)
        
    }

    private func setupUI() {
        view.backgroundColor = .white
        navigationItem.title = "All Tasks"
        
        // Add "Sort" button
        let sortButton = UIBarButtonItem(image: UIImage(systemName: "arrow.up.arrow.down"), style: .plain, target: self, action: #selector(sortTasksTapped))
        
        // Add "Add Task" button
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTaskTapped))
        
        navigationItem.rightBarButtonItems = [sortButton, addButton]

        searchBar.placeholder = "Search Tasks"
        searchBar.delegate = self
        searchBar.sizeToFit()
        view.addSubview(searchBar)

        weatherBar.backgroundColor = .systemGray6
        view.addSubview(weatherBar)
        weatherLabel.textAlignment = .center
        weatherLabel.font = UIFont.systemFont(ofSize: 14)
        weatherBar.addSubview(weatherLabel)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TaskTableViewCell.self, forCellReuseIdentifier: TaskTableViewCell.reuseIdentifier)
        view.addSubview(tableView)

        searchBar.translatesAutoresizingMaskIntoConstraints = false
        weatherBar.translatesAutoresizingMaskIntoConstraints = false
        weatherLabel.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            weatherBar.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            weatherBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            weatherBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            weatherBar.heightAnchor.constraint(equalToConstant: 40),
            
            weatherLabel.centerYAnchor.constraint(equalTo: weatherBar.centerYAnchor),
            weatherLabel.leadingAnchor.constraint(equalTo: weatherBar.leadingAnchor, constant: 10),
            weatherLabel.trailingAnchor.constraint(equalTo: weatherBar.trailingAnchor, constant: -10),
            
            tableView.topAnchor.constraint(equalTo: weatherBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    @objc func loadTasks() {
        viewModel?.fetchTasks()
    }
    
    private func setupTapGesture() {
          let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
          tapGesture.cancelsTouchesInView = false
          view.addGestureRecognizer(tapGesture)
      }

      @objc private func dismissKeyboard() {
          view.endEditing(true)
      }

    @objc private func sortTasksTapped() {
        let alert = UIAlertController(title: "Sort Tasks", message: "Choose sorting criteria", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Sort by Due Date", style: .default, handler: { [weak self] _ in
            self?.viewModel?.sortTasks(by: .dueDate)
        }))
        alert.addAction(UIAlertAction(title: "Sort by Priority", style: .default, handler: { [weak self] _ in
            self?.viewModel?.sortTasks(by: .priority)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    @objc private func addTaskTapped() {
        let taskDetailVC = TaskDetailViewController()
        taskDetailVC.viewModel = viewModel
        taskDetailVC.delegate = self
        navigationController?.pushViewController(taskDetailVC, animated: true)
    }

    private func bindViewModel() {
          viewModel?.$filteredTasks
              .receive(on: RunLoop.main)
              .sink(receiveValue: { [weak self] _ in
                  self?.tableView.reloadData()
              })
              .store(in: &cancellables)

      
      }

    private func bindWeatherService() {
        Publishers.CombineLatest3(NetworkResponse.$weatherDescription, weatherService.$temperature, weatherService.$locationName)
            .receive(on: RunLoop.main)
            .sink { [weak self] description, temperature, locationName in
                self?.weatherLabel.text = "\(locationName): \(description), \(temperature)°C"
            }
            .store(in: &cancellables)
    }
}

extension AllTasksViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.filteredTasks.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TaskTableViewCell.reuseIdentifier, for: indexPath) as! TaskTableViewCell
        cell.delegate = self
        if let task = viewModel?.filteredTasks[indexPath.row] {
            cell.configure(task: task)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let task = viewModel?.filteredTasks[indexPath.row] {
                viewModel?.deleteTask(task)
            }
        }
    }
}

extension AllTasksViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedTask = viewModel?.filteredTasks[indexPath.row] {
            let taskDetailVC = TaskDetailViewController()
            taskDetailVC.task = selectedTask
            taskDetailVC.viewModel = viewModel
            taskDetailVC.delegate = self
            navigationController?.pushViewController(taskDetailVC, animated: true)
        }
    }
}

extension AllTasksViewController: TaskTableViewCellDelegate {
    func didTapCompleteButton(on cell: TaskTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell),
              let task = viewModel?.filteredTasks[indexPath.row],
              let viewModel = viewModel else { return }

        handleTaskCompletion(task: task, viewModel: viewModel, tableView: tableView)
    }
}

extension AllTasksViewController: TaskDetailViewControllerDelegate {
    func didSaveTask() {
        loadTasks()
    }
}

extension AllTasksViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel?.searchTasks(with: searchText)
    }
}

extension AllTasksViewController : CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
           
            
            viewModel?.getWeatherForecasteData(req: WeatherRequest(key: "", coordinate: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), aqi: "no"), onCompletion: { NetworkResponse
                in
                print(NetworkResponse)
            })
            fetchLocationName(for: location)
        }
    }

    private func fetchLocationName(for location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let placemark = placemarks?.first, error == nil {
                self.locationName = placemark.locality ?? "Unknown Location"
            }
        }
    }
    
}
