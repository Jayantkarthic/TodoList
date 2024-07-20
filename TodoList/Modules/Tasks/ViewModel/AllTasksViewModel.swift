//
//  File.swift
//  TodoList
//
//  Created by Jayant Karthic on 16/07/24.
//

import Foundation
import CoreData
import Combine
import CoreLocation


protocol ErrorShowable {
    var showErrorAlert: Bool { get set }
    var errorMessage: String { get set }
}

protocol Loadable {
    var isLoading: Bool { get set }
}
	

final class AllTasksViewModel: ObservableObject,Loadable {
    @Published var tasks: [ToDoTask] = []
    @Published var filteredTasks: [ToDoTask] = []
    @Published var weatherDescription: String = ""
    @Published var temperature: Double = 0.0
    @Published var locationName: String = ""
    
    
    private var subscriptions = Set<AnyCancellable>()
    private var weatherForecastService: WeatherForecastService
    
    
    private var cancellables = Set<AnyCancellable>()
    private let context: NSManagedObjectContext
    
    
    @Published var isLoading = false
    


    init(context: NSManagedObjectContext,weatherForecastService: WeatherForecastService = .init()) {
        self.context = context
        self.weatherForecastService = weatherForecastService
        fetchTasks()
    }
    
    deinit {
        subscriptions.removeAll()
    }
    
    var completedTasks: [ToDoTask] {
        return tasks.filter { $0.isCompleted }
    }
    
    var uncompletedTasks: [ToDoTask] {
        return tasks.filter { !$0.isCompleted }
    }
    
    
    func fetchTasks() {
        tasks = fetchFromCoreData()
        filteredTasks = tasks
    }
    
    func addTask(title: String, description: String?, attachmentURL: URL?, priority: String, dueDate: Date) {
        let task = ToDoTask(context: context)
        task.title = title
        task.taskDescription = description
        task.attachmentURL = attachmentURL?.absoluteString
        task.priority = priority
        task.dueDate = dueDate
        task.isCompleted = false
        saveContext()
        tasks.append(task)
        filteredTasks = tasks
        postTasksUpdatedNotification()
    }
    
    func updateTask(_ task: ToDoTask, title: String, description: String?, attachmentURL: URL?, priority: String, dueDate: Date) {
        task.title = title
        task.taskDescription = description
        task.attachmentURL = attachmentURL?.absoluteString
        task.priority = priority
        task.dueDate = dueDate
        saveContext()
        postTasksUpdatedNotification()
    }
    
    func toggleTaskCompletion(_ task: ToDoTask) {
        task.isCompleted.toggle()
        saveContext()
        postTasksUpdatedNotification()
    }
    
    func deleteTask(_ task: ToDoTask) {
        context.delete(task)
        saveContext()
        fetchTasks()
    }
    
    func getAllTasks() -> [ToDoTask] {
        return tasks
    }
    
    func searchTasks(with query: String) {
        if query.isEmpty {
            filteredTasks = tasks
        } else {
            filteredTasks = tasks.filter { $0.title?.lowercased().contains(query.lowercased()) == true }
        }
    }
    
    func sortTasks(by criteria: SortCriteria) {
        switch criteria {
        case .dueDate:
            filteredTasks.sort { $0.dueDate ?? Date() < $1.dueDate ?? Date() }
        case .priority:
            filteredTasks.sort { $0.priority ?? "" < $1.priority ?? "" }
        }
    }
    
    private func fetchFromCoreData() -> [ToDoTask] {
        let fetchRequest: NSFetchRequest<ToDoTask> = ToDoTask.fetchRequest()
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching tasks: \(error)")
            return []
        }
    }
    
    private func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    private func postTasksUpdatedNotification() {
        NotificationCenter.default.post(name: .tasksUpdated, object: nil)
    }
}

enum SortCriteria {
    case dueDate
    case priority
}



extension AllTasksViewModel {
    func getWeatherForecasteData(req: WeatherRequest, onCompletion:@escaping(NetworkResponse)->(Void))     {
        weatherForecastService.getWeatherForecastData(req)
        
            .receive(on: RunLoop.main)
            .handleEvents(receiveSubscription: { [weak self] _ in
                self?.isLoading = true
            }, receiveCompletion: { [weak self]  _ in
                self?.isLoading = false
            }, receiveCancel: { [weak self] in
                self?.isLoading = false
            })
            .sink(receiveCompletion: { complition in
                switch complition {
                case .finished:
                    print("Finished")
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }) { NetworkResponse in
            
                onCompletion(NetworkResponse)
                DispatchQueue.main.async {
                    print(NetworkResponse)
                    self.locationName = NetworkResponse.location.name
                    self.weatherDescription = NetworkResponse.current.condition.text
                    self.temperature = NetworkResponse.current.temp_c
             
                }
            }
            .store(in: &subscriptions)
    }
}
