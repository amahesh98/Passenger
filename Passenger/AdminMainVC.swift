//
//  AdminMainVC.swift
//  Passenger
//
//  Created by Ashwin Mahesh on 7/23/18.
//  Copyright © 2018 AshwinMahesh. All rights reserved.
//

import UIKit
import CoreData

class AdminMainVC: UIViewController {
    var drivingForId:Int?
    
    var tableData:[NSDictionary]=[]
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func creditsPushed(_ sender: UIButton) {
        performSegue(withIdentifier: "toCredits", sender: "admin")
    }
    
    @IBAction func homePushed(_ sender: UIButton) {
        performSegue(withIdentifier: "AdminToHomeSegue", sender: "AdminToHome")
    }
    @IBAction func drivePushed(_ sender: UIButton) {
        getDrivingForID()
    }
    @IBAction func addPushed(_ sender: UIButton) {
        performSegue(withIdentifier: "AdminMainToAddSegue", sender: "AdminMainToAdd")
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let orgID = sender as? Int{
            let dest = segue.destination as! DriveQueueVC
            dest.orgID=orgID
        }
        
        if let indexPath = sender as? IndexPath{
            let cell = tableView.cellForRow(at: indexPath) as! AdminOrgCell
            if segue.identifier=="AdminMainToWaitSegue"{
                let dest = segue.destination as! AdminWaitVC
//                dest.orgID = cell.orgID!
                dest.orgNameText = cell.nameLabel.text!
            }
            else{
                let dest = segue.destination as! AdminDriversVC
                dest.orgID = cell.orgID!
                dest.orgNameText = cell.nameLabel.text!
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource=self
        tableView.delegate=self
        tableView.rowHeight=100
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        fetchOrganizations()
    }
    override func viewWillAppear(_ animated: Bool) {
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchOrganizations(){
        tableData=[]
        var id:Int64 = -1
        let request:NSFetchRequest<User> = User.fetchRequest()
        do{
            let result = try context.fetch(request).first
            id=result!.id
        }
        catch{
            print(error)
        }
        
        if let urlReq = URL(string: "\(SERVER.IP)/getYourOrganizations/"){
            var request = URLRequest(url: urlReq)
            request.httpMethod="POST"
            let bodyData = "id=\(id)"
            request.httpBody = bodyData.data(using:.utf8)
            let session = URLSession.shared
            let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
                do{
                    if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary{
                        let response = jsonResult["response"] as! NSDictionary
                        let organizations = response["organizations"] as! NSMutableArray
                        for organization in organizations{
                            let orgFixed = organization as! NSDictionary
                            self.tableData.append(orgFixed)
//                            print(self.tableData)
                        }
                        DispatchQueue.main.async{
                            self.tableView.reloadData()
                        }
                    }
                }
                catch{
                    print(error)
                }
            }
            task.resume()
        }
        
    }

}
extension AdminMainVC:UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AdminOrgCell", for: indexPath) as! AdminOrgCell
        let currentOrg=tableData[indexPath.row]
        cell.nameLabel.text = currentOrg["name"] as! String
        let status = currentOrg["approved"] as! Int16
        if status==0{
            cell.statusLabel.text = "Pending"
        }
        else if status==1{
            cell.statusLabel.text = "Approved"
        }
        cell.orgID=currentOrg["id"] as! Int
        cell.delegate=self
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! AdminOrgCell
        if cell.statusLabel.text! == "Pending"{
            DispatchQueue.main.async{
                self.performSegue(withIdentifier: "AdminMainToWaitSegue", sender: indexPath)
            }
        }
        else{
            DispatchQueue.main.async{
                self.performSegue(withIdentifier: "AdminMainToViewSegue", sender: indexPath)
            }
        }
    }
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .normal, title: "Delete") { (action, view, finishAnimation) in
            let alert = UIAlertController(title:"Confirm", message: "Are you sure you want to delete this organization?", preferredStyle: .alert)
            let yes = UIAlertAction(title:"Yes", style:.default, handler:{
                action in
                finishAnimation(true)
                self.deleteOrganization(cell: tableView.cellForRow(at: indexPath) as! AdminOrgCell)
            })
            let no = UIAlertAction(title:"No", style:.cancel){
                action in
                finishAnimation(true)
            }
            alert.addAction(yes)
            alert.addAction(no)
            
            self.present(alert, animated:true)
//            finishAnimation(true)
        }
        delete.backgroundColor = UIColor.red
        let swipeConfig = UISwipeActionsConfiguration(actions:[delete])
        return swipeConfig
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let info = UIContextualAction(style: .normal, title: "Info") { (action, view, finishAnimation) in
            let cell = tableView.cellForRow(at: indexPath) as! AdminOrgCell
            if cell.statusLabel.text! == "Pending"{
                DispatchQueue.main.async{
                    self.performSegue(withIdentifier: "AdminMainToWaitSegue", sender: indexPath)
                }
            }
            else{
                DispatchQueue.main.async{
                    self.performSegue(withIdentifier: "AdminMainToViewSegue", sender: indexPath)
                }
            }
        }
        info.backgroundColor = UIColor.init(red: 114.0/255.0, green: 136.0/255.0, blue: 247.0/255.0, alpha: 1)
        let swipeConfig = UISwipeActionsConfiguration(actions: [info])
        return swipeConfig
    }
}
extension AdminMainVC:AdminOrgCellDelegate{
    func removePushed(cell:AdminOrgCell) {
        print("Removing organization with id \(cell.orgID!)")
        DispatchQueue.main.async{
            let alert = UIAlertController(title:"Confirm", message: "Are you sure you want to delete this organization?", preferredStyle: .alert)
            let yes = UIAlertAction(title:"Yes", style:.default, handler:{
                action in
                self.deleteOrganization(cell: cell)
            })
            let no = UIAlertAction(title:"No", style:.cancel, handler:nil)
            alert.addAction(yes)
            alert.addAction(no)

            self.present(alert, animated:true)
        }
    }
    
    func deleteOrganization(cell:AdminOrgCell){
        let indexPath = self.tableView.indexPath(for: cell)
        if let urlReq = URL(string: "\(SERVER.IP)/deleteOrganization/"){
            var request = URLRequest(url:urlReq)
            request.httpMethod="POST"
            let bodyData="id=\(cell.orgID!)"
            request.httpBody = bodyData.data(using:.utf8)
            let session = URLSession.shared
            let task = session.dataTask(with: request) { (data, response, error) in
                do{
                    if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary{
                        let response = jsonResult["response"] as! String
                        if response=="Organization does not exist"{
                            DispatchQueue.main.async{
                                let alert = UIAlertController(title:"Deletion Error", message:"We could not delete this organization.", preferredStyle: .alert)
                                let ok = UIAlertAction(title:"OK", style:.default, handler:nil)
                                alert.addAction(ok)
                                self.present(alert, animated:true)
                                return
                            }
                        }
                        else{
                            DispatchQueue.main.async{
                                let alert = UIAlertController(title:"Deletion Success", message:"Organization successfully deleted", preferredStyle: .alert)
                                let ok = UIAlertAction(title:"OK", style:.default, handler:nil)
                                alert.addAction(ok)
                                self.present(alert, animated:true)
                            }
                            DispatchQueue.main.async{
                                self.tableData.remove(at: indexPath!.row)
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
                catch{
                    print(error)
                }
            }
            task.resume()
        }
    }
}
extension AdminMainVC{
    func getDrivingForID(){
        var id:Int64?
        let fetchRequest:NSFetchRequest<User> = User.fetchRequest()
        do{
            id = try context.fetch(fetchRequest).first!.id
        }
        catch{
            print(error)
        }
        
        if let urlReq = URL(string: "\(SERVER.IP)/getDrivingForId/"){
            var request = URLRequest(url:urlReq)
            request.httpMethod = "POST"
            let bodyData="userID=\(id!)"
            request.httpBody = bodyData.data(using: .utf8)
            let session = URLSession.shared
            let task = session.dataTask(with: request as URLRequest){
                data, response, error in
                do{
                    if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary{
//                        print(jsonResult)
                        let response = jsonResult["response"] as! String
                        if response=="success"{
                            self.drivingForId = jsonResult["drivingFor_ID"] as! Int
//                            print(self.drivingForId!)
                            if self.drivingForId! > -1{
                                DispatchQueue.main.async{
                                    self.performSegue(withIdentifier: "AdminToDriverSegue", sender: self.drivingForId!)
                                }
                            }
                            else if self.drivingForId! == -1{
                                DispatchQueue.main.async{
                                    self.performSegue(withIdentifier: "AdminToDriverNoneSegue", sender: "AdminToDriverNone")
                                }
                            }
                            
                        }
                    }
                }
                catch{
                    print(error)
                }
            }
            task.resume()
        }
    }
}
