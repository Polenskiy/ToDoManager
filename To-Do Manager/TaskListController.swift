//
//  TaskListController.swift
//  To-Do Manager
//
//  Created by Daniil Polenskii on 25.08.2023.
//

import UIKit

class TaskListController: UITableViewController {
    
    //Хранилище задач
    private var tasksStorage: TasksStorageProtocol = TaskStorage()
    
    //Коллекция задач
    ///Типом данных является словарь,
    /// ключом которого является тип задачи: важная или текущая.
    ///  Значением этого словаря является протокол описывающий сущность "Задача"
    private var tasks: [TaskPriority: [TaskProtocol]] = [:] {
        //наблюдатель didSet полсе того как tasks обновляется
        didSet {
            for (tasksGroupPriority, tasksGroup) in tasks {
                tasks[tasksGroupPriority] = tasksGroup.sorted{ task1, task2 in
                    let task1position = tasksStatusPosition.firstIndex(of: task1.status) ?? 0
                    let task2position = tasksStatusPosition.firstIndex(of: task2.status) ?? 0
                    return task1position < task2position
                }
            }
            //сохранение задач
            var savingArray: [TaskProtocol] = []
            tasks.forEach { _, value in
                savingArray += value
            }
            tasksStorage.saveTasks(savingArray)
        }
    }
    
    ///порядок отображения секций по типам
    ///индекс в массиве соответствует индексу секции в таблице
    ///Для того чтобы определить порядок порядок отображения секций используется это свойство
    private var sectionTypesPosition: [TaskPriority] = [.important, .normal]
    
    //порядок отображения задач по их статусу
    var tasksStatusPosition: [TaskStatus] = [.planned, .completed]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //загрузка задач
        loadTasks()
        //кнопка активации режима редактирования
        //c помощью свойства editButtonItem был включен режим редактирования,
        //но задачи пока еще не удалаются
        navigationItem.leftBarButtonItem = editButtonItem
    }
    /// с помощью этого метода будет происходить загрузка из хранилища всех задач
    /// с последующим разбором и размещением по элементам словаря tasks
    private func loadTasks() {
        //подготовка коллекции с задачами
        ///будем использовать только те задачи,
        ///для которых определена секция в таблице
        sectionTypesPosition.forEach { taskType in
            tasks[taskType] = []
        }
        // загрузка и разбор задач из хранилища
        tasksStorage.loadTasks().forEach { task in
            tasks[task.type]?.append(task)
        }
    }
    
    // MARK: - Table view data source
    // количество секций в таблице
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tasks.count
    }
    // количество строк в определенной секции
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //определяем приоритет задач, соответсвующий текущей секции
        let taskType = sectionTypesPosition[section]
        guard let currentTasksType = tasks[taskType] else {
            return 0
        }
        return currentTasksType.count
    }
    
    ///метод cellForRowAt возвращает сконфигурированную ячейку для конкретной строки
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return getConfiguredTaskCell_constraints(for: indexPath)
//        return getConfiguredTaskCell_stack(for: indexPath)
    }
    // ячейка на основе ограничений
    private func getConfiguredTaskCell_constraints(for indexPath: IndexPath) -> UITableViewCell {
        //загружаем прототип ячейки по идентификатору
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCellConstraints", for: indexPath)
        //получаем данные о задаче, которую необходимо вывести в ячейке
        let taskType = sectionTypesPosition[indexPath.section]
        guard let currentTask = tasks[taskType]?[indexPath.row] else {
            return cell
        }
        // текстовая метка символа
        let symbolLabel = cell.viewWithTag(1) as? UILabel
        // текстовая метка названия задачи
        let textLabel = cell.viewWithTag(2) as? UILabel
        
        //изменяем символ в ячейке
        symbolLabel?.text = getSymbolForTask(with: currentTask.status)
        //изменяем текст в ячейке
        textLabel?.text = currentTask.title
        
        //изменяем цвет текста и символа
        if currentTask.status == .planned {
            textLabel?.textColor = .black
            symbolLabel?.textColor = .black
        } else {
            textLabel?.textColor = .lightGray
            symbolLabel?.textColor = .lightGray
        }
        
        
        return cell
    }
    
    //ячейка на основе стека
    private func getConfiguredTaskCell_stack(for indexPath: IndexPath) -> UITableViewCell {
        //загружаем прототип ячеки по идентификатору
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCellStack", for: indexPath) as! TaskCell
        //получаем данные о задаче, которые необходимо вывести в ячейке
        let taskType = sectionTypesPosition[indexPath.section]
        guard let currentTask = tasks[taskType]?[indexPath.row] else {
            return cell
        }
        
        //изменяем текст в ячейке
        cell.title.text = currentTask.title
        //изменяем символ в ячейке
        cell.symbol.text = getSymbolForTask(with: currentTask.status)
        //изменяем цвет текста
        if currentTask.status == .planned {
            cell.title.textColor = .black
            cell.symbol.textColor = .black
        } else {
            cell.title.textColor = .lightGray
            cell.symbol.textColor = .lightGray
        }
        return cell
    }
    
    //Вернем символ для соответсвующего типа 3адачи
    private func getSymbolForTask(with status: TaskStatus) -> String {
        var resultSymbol: String
        if status == .planned {
            resultSymbol = "\u{25CB}"
        } else if status == .completed {
            resultSymbol = "\u{25C9}" } else {
                resultSymbol = "" }
        return resultSymbol
    }
    
    //метод для заголовка в секции
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title: String?
        let tasksType = sectionTypesPosition[section]
        if tasksType == .important {
            title = "Важные"
        } else if tasksType == .normal {
            title = "Текущие" }
        return title
    }
    
    //Этот метод срабатывает при нажатии на строку таблицы
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //проверяем существование задачи
        //IndexPath.section – индекс секции табличного представления,
        //в которой было совершено нажатие.
        //IndexPath.row –индекс строки табличного представления,
        //накоторую было выполнено нажатие.
        let taskType = sectionTypesPosition[indexPath.section]
        guard let currentTask = tasks[taskType]?[indexPath.row] else {
            return
        }
        // убеждаемся, что задача не является выполненной
        guard currentTask.status == .planned else {
            // снимаем выделение со строки
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        // отмечаем задачу как выполненную
        tasks[taskType]![indexPath.row].status = .completed
        //перезагружаем секцию таблицы
        tableView.reloadSections(IndexSet(arrayLiteral: indexPath.section), with: .automatic)
    }
    
    //функция изменения статуса задачи с «выполнена» на «запланирована»
    //с помощью свайпа
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        //получаем данные о задаче, по которой осуществлен свайп
        let taskType = sectionTypesPosition[indexPath.section]
        guard let _ = tasks[taskType]?[indexPath.row] else {
            return nil
        }
        
        //Действие, отображаемое при смахивании пользователем строки таблицы
        //изменение статуса на "запланирована"
        let actionSwipeInstance = UIContextualAction(style: .normal, title: "не выполнена") {
            _,_,_ in
            // в параметр handler поместили замыкание
            self.tasks[taskType]?[indexPath.row].status = .planned
            //Перезагрузка указанных разделов с использованием предоставленного эффекта анимации.
            self.tableView.reloadSections(IndexSet(arrayLiteral: indexPath.section), with: .automatic)
        }
        
        // действие для перехода к экрану редактирования
        let actionEditInstance = UIContextualAction(style: .normal, title: "Изменить") {_,_,_ in
            // загрузка сцены со storyboard
            let editScreen = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "TaskEditController") as! TaskEditController
            editScreen.taskText = self.tasks[taskType]![indexPath.row].title
            editScreen.taskType = self.tasks[taskType]![indexPath.row].type
            editScreen.taskStatus = self.tasks[taskType]![indexPath.row].status
            //передача обработчика для сохранения задачи
            editScreen.doAfterEdit = { [unowned self] title, type, status in
                let editTask = Task(title: title, type: type, status: status)
                tasks[taskType]![indexPath.row] = editTask
                tableView.reloadData()
            }
          // переход к экрану редактирования
            self.navigationController?.pushViewController(editScreen, animated: true)
        }
        // изменяем цвет фона кнопки с действием
        actionEditInstance.backgroundColor = .darkGray
        
        // создаем объект, описывающий доступные действия
        // в зависимости от статуса задачи будет отображено 1 или 2 действия
        let actionsConfiguration: UISwipeActionsConfiguration
        if tasks[taskType]![indexPath.row].status == .completed {
            actionsConfiguration = UISwipeActionsConfiguration(actions: [actionEditInstance, actionSwipeInstance])
        } else {
            actionsConfiguration = UISwipeActionsConfiguration(actions: [actionEditInstance])
        }
        return  actionsConfiguration
    }
    
    //метод осуществлющий удаление задач
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let taskType = sectionTypesPosition[indexPath.section]
        //удаляем задачу
        tasks[taskType]?.remove(at: indexPath.row)
        //удаляем строку
        tableView.deleteRows(at: [indexPath], with: .automatic)
        
    }
    
    //ручная сортировка списка задач
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        //секция из которой происходит перемещение
        let taskTypeFrom = sectionTypesPosition[sourceIndexPath.section]
        //секция в которую прооисходит перемещение
        let taskTypeTo =  sectionTypesPosition[destinationIndexPath.section]
        //безопасно извлекаем задачу, тем самым копирем ее
        guard let movedTask = tasks[taskTypeFrom]?[sourceIndexPath.row] else {
            return
        }
        //удаляем задачу с места, откуда она была перенесена
        tasks[taskTypeFrom]!.remove(at: sourceIndexPath.row)
        //вставляем задачу на новую позицию
        tasks[taskTypeTo]!.insert(movedTask, at: destinationIndexPath.row)
        //если секция изменилась, изменяем тип задач в соответствии с новой позицией
        if taskTypeFrom != taskTypeTo {
            tasks[taskTypeTo]![destinationIndexPath.row].type = taskTypeTo
        }
        tableView.reloadData()
    }
    
    //
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCreateScreen" {
            let destination = segue.destination as! TaskEditController
            destination.doAfterEdit = { [unowned self] title, type, status in
                let newTask = Task(title: title,  type: type, status: status)
                tasks[type]?.append(newTask)
                tableView.reloadData()
            }
        }
    }
    
    //получение списка задач, их разбор и установка в свойство tasks
    func setTasks(_ tasksCollection: [TaskProtocol]) {
        //подготовка коллекции с задачами
        //будем использовать только те задачи, для которых определена секция
        sectionTypesPosition.forEach { taskType in
            tasks[taskType] = []
        }
        //загрузка и разбор задач из хранилища
        tasksCollection.forEach { task in
            tasks[task.type]?.append(task)
        }
    }
}
