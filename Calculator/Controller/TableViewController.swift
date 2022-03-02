//
//  TableViewController.swift
//  Calculator
//
//  Created by user213353 on 2/19/22.
//

import UIKit

class TableViewController: UITableViewController {

    var calculator: CalculatorModel? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self        
    }
    
    @IBAction func DelateHistory(_ sender: UIBarButtonItem) {
        calculator?.arrayOperations.removeAll()
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calculator?.arrayOperations.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? TableViewCell {
            
            let item = calculator?.arrayOperations[indexPath.row] ?? ""
            cell.refresh(item)
        return cell
        }
        
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
        
    }
}
