//
//  ViewController.swift
//  aaaaa
//
//  Created by Emre Karadavut on 9/21/22.
//


import UIKit
import CoreData

class ViewController: UIViewController {

    var alertController = UIAlertController()
    @IBOutlet weak var tableView: UITableView!
    
    
    var data = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        fetch()
    
    
    }
  
    
    @IBAction func didRemoveButtonItemTapped(_ sender: UIBarButtonItem)
    {
        presentAlert(title: "Uyarı",
                     message: "Her şey silinecek :(",
                     cancelButtonTitle: "Yoo",
                     defaultButtonTitle: "Evet") { _ in
                                                   // self.data.removeAll()
                                                    //self.tableView.reloadData()
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            
            let managedObjectContext = appDelegate?.persistentContainer.viewContext
            
            let fetchReq = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: "Listitem"))
            
            do {try managedObjectContext?.execute(fetchReq)}
            catch{print(error)}
            self.fetch()
            
        }
      
    }
    
    @IBAction func didAddBarButtonItemTapped(_ sender: UIBarButtonItem)
    {
       presentAddAlert()
    }
    func presentAddAlert()
    {
        presentAlert(title: "Yeni eleman ekle",
                     message: nil,
                     cancelButtonTitle: "Vazgeç",
                     isTextFieldAvailable: true,
                     defaultButtonTitle: "Ekle",
                     defaultButtonHandler:  { _ in
                        let text = self.alertController.textFields?.first?.text
                        if text != "" {
                            let appDelegate = UIApplication.shared.delegate as? AppDelegate
                            
                            let managedObjectContext = appDelegate?.persistentContainer.viewContext
                            
                            let entity = NSEntityDescription.entity(forEntityName: "Listitem", in: managedObjectContext!)
                            
                            let Listitem = NSManagedObject(entity: entity!, insertInto: managedObjectContext)
                            
                            Listitem.setValue(text, forKey: "title")
            
                            try? managedObjectContext?.save()
                            
                            self.fetch()
                        }
                        else
                        {
                            self.presentWarningAlert()
                        }
                     }
        )
    }
    
    
    func presentWarningAlert()
    {
        presentAlert(title: "Uyarı",
                     message: "Boş eleman giremezsin :(",
                     cancelButtonTitle: "Tamam")
    }
    func presentAlert(title: String?,
                      message: String?,
                      prefferedStyle: UIAlertController.Style = .alert,
                      cancelButtonTitle: String?,
                      isTextFieldAvailable: Bool = false,
                      defaultButtonTitle: String? = nil,
                      defaultButtonHandler: ((UIAlertAction)->Void)? = nil)
    {
        
        
        alertController = UIAlertController(title: title,
                                            message: message,
                                            preferredStyle: prefferedStyle)
      
        if defaultButtonTitle != nil {
            
            let defaultButton = UIAlertAction(title: defaultButtonTitle, style: .default, handler: defaultButtonHandler)
            alertController.addAction(defaultButton)
        }
        
        let cancelButton = UIAlertAction(title: cancelButtonTitle, style: .cancel)
        
        if isTextFieldAvailable{
            alertController.addTextField()
        }
        alertController.addAction(cancelButton)
      
        present(alertController, animated: true)
    }
    func fetch()
    {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        
        let managedObjectContext = appDelegate?.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Listitem")
        
        data = try! managedObjectContext!.fetch(fetchRequest)
        
        tableView.reloadData()
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
        }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell", for: indexPath)
        let listItem = data[indexPath.row]
        cell.textLabel?.text = listItem.value(forKey: "title") as? String
        return cell
        }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .normal,
                                              title: "Sil") { (_, _, _) in
            
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            
            let managedObjectContext = appDelegate?.persistentContainer.viewContext
            
            managedObjectContext?.delete(self.data[indexPath.row])
            
            try? managedObjectContext?.save()
            
            self.fetch()
        }
        
        let editAction = UIContextualAction(style: .normal,
                                              title: "Düzenl") { (_, _, _) in
            self.presentAlert(title: "Elemanı düzenle",
                              message: nil,
                              cancelButtonTitle: "Vazgeç",
                              isTextFieldAvailable: true,
                              defaultButtonTitle: "Düzenle",
                              defaultButtonHandler:  { _ in
                                let text = self.alertController.textFields?.first?.text
                                if text != "" {
                                   // self.data[indexPath.row] = text!
                                    let appDelegate = UIApplication.shared.delegate as? AppDelegate
                                    
                                    let managedObjectContext = appDelegate?.persistentContainer.viewContext
                                    
                                    self.data[indexPath.row].setValue(text, forKey: "title")
                                    
                                    if managedObjectContext!.hasChanges{
                                        try? managedObjectContext?.save()
                                    }
                                    self.tableView.reloadData()
                                }
                                else
                                {
                                    self.presentWarningAlert()
                                }
                              }
                            
            )
            self.tableView.reloadData()
        }
        deleteAction.backgroundColor = .systemRed
        let config = UISwipeActionsConfiguration(actions: [deleteAction,editAction])
        
        return config
    }
}
