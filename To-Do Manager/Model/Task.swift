//
//  Task.swift
//  To-Do Manager
//
//  Created by Daniil Polenskii on 25.08.2023.
//

import Foundation

//Тип задачи
enum TaskPriority {
    // текущая
    case normal
    // важная
    case important

}

//Состояние задачи
//Мы установили тип Int в качестве связанного для TasksPriority
enum TaskStatus: Int {
    // запланированная
    case planned
    // завершенная
    case completed
}

// требования к типу, описывающему сущность "Задача"
    protocol TaskProtocol {
        //название
        var title: String { get set }
        //тип
        var type: TaskPriority { get set}
        // статус
        var status: TaskStatus { get set}
    }

// сущность "Задача"
struct Task: TaskProtocol {
    var title: String
    var type: TaskPriority
    var status: TaskStatus
}
