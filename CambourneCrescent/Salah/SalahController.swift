//
//  SalahController.swift
//  CambourneCrescent
//
//  Created by Ahmed, Shakeel on 27/07/2024.
//

import UIKit
import UserNotifications

class SalahController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    private var activity = UIActivityIndicatorView(style: .large)
    private var datasource = [SalahAPIResponse]()
    private let maxNotificationLimit = 63
    private var notificationsCount = 1
  
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        navigationItem.title = "Salah"
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if let error {
                print(error.localizedDescription)
            }
        }
      NotificationCenter.default.addObserver(self, selector: #selector(load),  name: NSNotification.Name("loadSalah"), object: nil)
      load()
    }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if !datasource.isEmpty {
      scrollToToday()
    }
  }
    
  private func scrollToToday() {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd MMM"
    let date = dateFormatter.string(from: Date())
    if let index = datasource.firstIndex(where: { $0.date == date}) {
      tableView.scrollToRow(at: IndexPath(item: 0, section: index), at: .top, animated: true)
    }
  }
  
  @objc func load() {
    addActivity()
    Task(priority: .background) {
        datasource = await Global.shared.getSalahTimings()
        await LocalNotifications.shared.scheduleNotificaitons()
        Task { @MainActor in
            tableView.reloadData()
            activity.stopAnimating()
        }
    }
  }
  
    private func addActivity() {
        
        view.addSubview(activity)
        activity.translatesAutoresizingMaskIntoConstraints = false
        activity.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activity.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        activity.startAnimating()
    }
    
    // MARK:- TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        datasource.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCell(withIdentifier: "SectionHeaderCell")
        let section = datasource[section]
        (header?.viewWithTag(1) as? UILabel)?.text = section.day + " " + section.date
        return header
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell: SalahCell
      let section = datasource[indexPath.section]
      let model = section.namaz[indexPath.row]
      
      if !model.jamat.isEmpty && !model.sun.isEmpty {
        cell = tableView.dequeueReusableCell(withIdentifier: "FajrSalahCell", for: indexPath) as! SalahCell
      } else if !model.jamat.isEmpty {
        cell = tableView.dequeueReusableCell(withIdentifier: "JamaatSalahCell", for: indexPath) as! SalahCell
      } else {
        cell = tableView.dequeueReusableCell(withIdentifier: "SalahCell", for: indexPath) as! SalahCell
      }
      
      cell.nameLabel?.text = model.salahName(day: section.day)
      cell.startTimeLabel?.text = "Starts: \(model.start)"
      cell.jamaatTimeLabel?.text = "Jamaat: \(model.jamat) @\(model.loc)"
      cell.sunriseTimeLabel?.text = "Sunrise: \(model.sun)"
      return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = datasource[indexPath.section].namaz[indexPath.row]
        if !model.loc.isEmpty {
            performSegue(withIdentifier: "showMap", sender: model)
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showMap" {
            guard let namaz = sender as? SalahModel else {
                print("Invalid data passed to showMap")
                return
            }
            let controller = segue.destination as! MapController
            switch namaz.loc.lowercased() {
            case "hub","hub-m":
                controller.location = .hub
            case "ncp":
                controller.location = .NCP
            case "bs-h":
                controller.location = .BlueSchool
            case "cvc":
                controller.location = .cvc
            case "sp":
                controller.location = .sp
            case "lcp":
                controller.location = .lcp
            default:
                break
            }
        }
    }
}
