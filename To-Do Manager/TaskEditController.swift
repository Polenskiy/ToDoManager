//
//  TaskEditController.swift
//  To-Do Manager
//
//  Created by Daniil Polenskii on 15.09.2023.
//

import UIKit

class TaskEditController: UITableViewController {
    
    @IBOutlet var taskTitle: UITextField!
    @IBOutlet var taskTypeLabel: UILabel!
    @IBOutlet var taskStatusSwitch: UISwitch!
    
    //вызывается при нажатии кнопки save
    @IBAction func saveTask(_ sender: UIBarButtonItem) {
        //получаем актуальные значения
        let title = taskTitle.text ?? ""
        let type = taskType
        let status: TaskStatus = taskStatusSwitch.isOn ? .completed : .planned
        //вызываем обработчик
        doAfterEdit?(title, type, status)
        //возвращемся к предыдущему экрану
        navigationController?.popViewController(animated: true)
    }
    
    //параметры задачи
    //в случае операции редактирования, сцена будет брать эти данные
    //Эти данные приходят сюда из контроллера TaskEditController
    var taskText: String = ""
    var taskType: TaskPriority = .important
    var taskStatus: TaskStatus = .completed
    
    //словарь соответствия типа и строквого значения
    private var taskTitles: [TaskPriority: String] = [
        .important: "Важная",
        .normal: "Текущая"
    ]
    
    //всякий раз при переходе к экрану создания свойству doAfterEdit будет инициализироваться
    //замыкание, определяющее дальнейшую судьбу измененных значений
    //данное замыкание будет захватывать ссылку на контроллер List и вносить в
    //свойство task необходимые изменения
    var doAfterEdit: ((String, TaskPriority, TaskStatus) -> Void)?
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //в случае, если переход к сцене будет произведен с целью
        //редактирвания задачи, ее название должно отобразиться
        //в текстовом поле сразу после перехода к сцене
        
        //обновление текстового поля с названием задачи
        taskTitle?.text = taskText
        
        //обновление метки в соответствии с текущим типом
        taskTypeLabel?.text = taskTitles[taskType]
        
        //обновляем статус задачи
            taskStatusSwitch.isOn = taskStatus == .completed
    }
    
    //передача данных от экрана создания к экрану выбора типа
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toTaskTypeScreen" {
            //ссылка на контроллер назначения
            let destination = segue.destination as! TaskTypeController
            //передача выбранного типа
            destination.selectedType = taskType
            //передча обработчика выбранного типа
            destination.doAfterTypeSelected = { [unowned self] selectedType in
                taskType = selectedType
                //обновляем метку с текущим типом
                taskTypeLabel?.text = taskTitles[taskType]
                
            }
        }
    }
    
    
}


