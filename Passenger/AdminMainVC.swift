//
//  AdminMainVC.swift
//  Passenger
//
//  Created by Ashwin Mahesh on 7/23/18.
//  Copyright © 2018 AshwinMahesh. All rights reserved.
//

import UIKit

class AdminMainVC: UIViewController {

    var tableData:[String]=["Pike"]
    @IBOutlet weak var tableView: UITableView!
    @IBAction func homePushed(_ sender: UIButton) {
        performSegue(withIdentifier: "AdminToHomeSegue", sender: "AdminToHome")
    }
    @IBAction func drivePushed(_ sender: UIButton) {
//        performSegue(withIdentifier: "AdminToDriverNoneSegue", sender: "AdminToDriverNone")
        performSegue(withIdentifier: "AdminToDriverSegue", sender: "AdminToDriver")
    }
    @IBAction func addPushed(_ sender: UIButton) {
        performSegue(withIdentifier: "AdminMainToAddSegue", sender: "AdminMainToAdd")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource=self
        tableView.delegate=self
        tableView.rowHeight=100
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
extension AdminMainVC:UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AdminOrgCell", for: indexPath) as! AdminOrgCell
        cell.nameLabel.text = "Pi Kappa Alpha"
        cell.statusLabel.text = "Approved"
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        performSegue(withIdentifier: "AdminMainToWaitSegue", sender: "AdminMainToWait")
        performSegue(withIdentifier: "AdminMainToViewSegue", sender: "AdminMainToView")
    }
}