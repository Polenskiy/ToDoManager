//
//  TaskTypeController.swift
//  To-Do Manager
//
//  Created by Daniil Polenskii on 16.09.2023.
//

import UIKit
//В задачи контроллера TaskTypeController входит только вывод доступных типов,
//передча выбранного типа обратно путем вызова замыкания и переход к предыдущему экрану
//и переход к предыдущему экрану в навигационном стеке
class TaskTypeController: UITableViewController {

    //кортеж описывающий тип задачи
    //объявление псевдонима типа вводит именованный псевдоним
    //существующего типа в программу
    typealias TypeCellDescription = (type: TaskPriority, title: String, description: String)
    
    //сделать что-то после выбора типа
    //сюда передается замыкание из TaskTypeController
    var doAfterTypeSelected: ((TaskPriority) -> Void)?
    
    //коллекция доступных типов задач с их описанием
    private var taskTypesInformation: [TypeCellDescription] = [
        (type: .important, title: "Важная", description: "Такой тип задач является наиболее приоритетным для выполнения. Все важные задачи выводятся в самом верху списка задач" ),
        (type: .normal, title: "Текущая", description: "Задача с обычным приоритетом")
    ]
    
    //выбранный приоритет
    //передается из TaskEditController
    var selectedType: TaskPriority = .normal

    override func viewDidLoad() {
        super.viewDidLoad()
        //получение значения типа UINib, соответствующее xib-файлу кастомной ячейки
        let cellTypeNib = UINib(nibName: "TaskTypeCell", bundle: nil)
        //регистрация кастомной ячейки в табличном представлении
        tableView.register(cellTypeNib, forCellReuseIdentifier: "TaskTypeCell")
    }
    
    //метод для обработки выбора заначения.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //получаем выбранный тип
        let selectedType = taskTypesInformation[indexPath.row].type
        //вызов обработчика(сделать что-то после выбора типа)
        //Этот обработчик будет выводить в TaskEditController выбранный приоритет
        doAfterTypeSelected?(selectedType)
        //переход к предыдущему экрану
        navigationController?.popViewController(animated: true)
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskTypesInformation.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //получение переиспользуемой кастомной ячейки по ее идентификтору
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskTypeCell", for: indexPath) as! TaskTypeCell
        //получаем текущий элемент, информация о котором должна быть выведена в строке
        let typeDescription = taskTypesInformation[indexPath.row]
        //заполняем ячейку данными
        cell.typeTitle.text = typeDescription.title
        cell.typeDescription.text = typeDescription.description
        //если тип является выбранным, то отмечаем его галочкой
        if selectedType == typeDescription.type {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
