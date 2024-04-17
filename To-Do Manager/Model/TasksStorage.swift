//
//  TasksStorage.swift
//  To-Do Manager
//
//  Created by Daniil Polenskii on 25.08.2023.
//

import Foundation

// Протокол, описывающий сущность "Хранилище задач"
protocol TasksStorageProtocol {
    func loadTasks() -> [TaskProtocol]
    func saveTasks(_ tasks: [TaskProtocol])
}

// Сущность "Хранилище задач"
class TaskStorage: TasksStorageProtocol {
    
    //Ссылка на хранилище
    // т.е отсюда метод loadTasks будет брать задачи,
    //а метод saveTasks будет сохранять сюда задачи
        private var storage = UserDefaults.standard
    
    // Ключ, по которому будет происходить сохранение
    // и загрузка хранилища из User Defaults
    var storageKey: String = "tasks"
    
    //Перечисление с ключами для записи в User Defaults
    private enum TaskKey: String {
        case title
        case type
        case status
    }
    //loadTask будет возвращать масив задач
    func loadTasks() -> [TaskProtocol] {
        //массив задач
        var resultTasks: [TaskProtocol] = []
        let  tasksFromStorage = storage.array(forKey: storageKey) as?  [[String:String]] ?? []
        for task in tasksFromStorage {
            guard let title = task[TaskKey.title.rawValue],
                  let typeRaw = task[TaskKey.type.rawValue],
                  let statusRaw = task[TaskKey.status.rawValue] else {
                //Оператор continue говорит циклу
                //прекратить текущую итерацию и начать новую
                continue
            }
            let type: TaskPriority = typeRaw == "important" ? .important : .normal
            let status: TaskStatus = statusRaw == "planned" ? .planned : .completed
            resultTasks.append(Task(title: title, type: type, status: status))
        }
        return resultTasks
    }
    
    //saveTask будет передаваться массив задач в storage
    func saveTasks(_ tasks: [TaskProtocol]) {
        var arrayForStorage: [[String:String]] = []
        tasks.forEach {task in
            var newElementForStorage: Dictionary<String, String> = [:]
            newElementForStorage[TaskKey.title.rawValue] = task.title
            newElementForStorage[TaskKey.type.rawValue] = (task.type == .important) ? "important" : "normal"
            newElementForStorage[TaskKey.status.rawValue] = (task.status == .planned) ? "planned" : "completed"
            arrayForStorage.append(newElementForStorage)
        }
        storage.set(arrayForStorage, forKey: storageKey)
    }
}
