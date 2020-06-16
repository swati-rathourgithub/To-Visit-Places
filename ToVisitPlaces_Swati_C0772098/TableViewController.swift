//
//  TableViewController.swift
//  ToVisitPlaces_Swati_C0772098
//
//  Created by user173890 on 6/16/20.
//  Copyright © 2020 user173890. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    @IBOutlet var tableview: UITableView!
    var places: [Place] = []
    var place: Place?

    override func viewDidLoad() {
        super.viewDidLoad()
        getPlaces()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func getPlaces()
    {
        if let data = UserDefaults.standard.data(forKey: "places")
        {
            do {
                let decoder = JSONDecoder()
                let places = try decoder.decode([Place].self, from: data)
                self.places = places
            } catch {
                print("Unable to Decode Notes (\(error))")
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return places.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "re")
        if cell == nil
        {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "re")
        }
        cell?.textLabel?.text = places[indexPath.row].title
        return cell!
    }
 
    

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            removePlace(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func removePlace(at: Int)
    {
        places.remove(at: at)
        savePlaces()
        place = nil
    }
    
    func savePlaces()
    {
        do
        {
            let encoder = JSONEncoder()
            let data = try encoder.encode(self.places)
            UserDefaults.standard.set(data, forKey: "places")
        } catch {
            print("Unable to Encode Array of Notes (\(error))")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getPlaces()
        tableview.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        place = places[indexPath.row]
        performSegue(withIdentifier: "identifier", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "identifier"
        {
            let vc = segue.destination as! ViewController
            vc.place = self.place
        }
    }

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
