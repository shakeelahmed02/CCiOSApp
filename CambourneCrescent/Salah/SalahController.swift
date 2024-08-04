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
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        navigationItem.title = "Salah Timings"
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("All set!")
            } else if let error {
                print(error.localizedDescription)
            }
        }
        addActivity()
        Task(priority: .background) {
            await getSalahTimings()
            await scheduleNotificaitons()
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        100
    }
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "SalahCell", for: indexPath) as! SalahCell
        let section = datasource[indexPath.section]
        let model = section.namaz[indexPath.row]
        cell.nameLabel.text = model.name
        cell.venueLabel.text = model.loc.isEmpty ? "N/A" : "@\(model.loc)"
        cell.timeLabel.text = model.jamat.isEmpty ? model.start : model.jamat
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = datasource[indexPath.section].namaz[indexPath.row]
        if !model.loc.isEmpty {
            performSegue(withIdentifier: "showMap", sender: model)
        }
    }
    
    private func getSalahTimings() async {
        guard let data = try? Data(contentsOf: salahLocalDataURL) else {
            print("Salah local data not available")
            await getSalahTimingsFromRemote()
            return
        }
        decodeSalahData(data: data)
    }
    
    private func getSalahTimingsFromRemote() async {
        let salahAPIURL = URL(string: "https://cambournecrescent.org/salah/index-app-json.php")!
        guard let data = try? await URLSession.shared.data(for: URLRequest(url: salahAPIURL)).0 else {
            print("SalahAPI not working")
            return
        }
        try? data.write(to: salahLocalDataURL, options: .atomic)
        decodeSalahData(data: data)
    }
    
    private func decodeSalahData(data: Data) {
        guard let salahs = try? JSONDecoder().decode([SalahAPIResponse].self, from: data) else {
            print("Could not decode data")
            return
        }
        datasource = salahs.filter { model in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM"
            guard let dateFromModel = dateFormatter.date(from: model.date) else {
                print("Can't parse date")
                return false
            }
            let salahDay = Calendar.current.component(.day, from: dateFromModel)
            let today = Calendar.current.component(.day, from: Date())
            return salahDay >= today
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
    
    private func scheduleNotificaitons() async {
        LocalNotifications.shared.removeAllPendingNotifications()
        LocalNotifications.shared.removeAllDeliveredNotifications()
        for data in datasource {
            let date = data.date
            
            guard let fajr = data.namaz.first(where: { $0.name.lowercased() == "fajr"}),
                  let dhohr = data.namaz.first(where: { $0.name.lowercased() == "dhohr"}),
                  let asr = data.namaz.first(where: { $0.name.lowercased() == "asr"}),
                  let magrib = data.namaz.first(where: { $0.name.lowercased() == "magrib"}),
                  let isha = data.namaz.first(where: { $0.name.lowercased() == "isha"}) else { continue }
            
            await scheduleNotificaiton(salah: fajr, salahDate: date)
            await scheduleNotificaiton(salah: dhohr, salahDate: date)
            await scheduleNotificaiton(salah: asr, salahDate: date)
            await scheduleNotificaiton(salah: magrib, salahDate: date)
            await scheduleNotificaiton(salah: isha, salahDate: date)
        }
    }

    private func scheduleNotificaiton(salah: SalahModel, salahDate: String) async {
        let currentYear = Calendar.current.component(.year, from: Date())
        let salahTime = salah.jamat
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy HH:mm"
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        let salahDateString = "\(salahDate) \(currentYear) \(salahTime)"
        guard let salahDate = dateFormatter.date(from: salahDateString) else { return }
        let salahNotTime = salahDate.timeIntervalSinceNow - 15*60
        if salahNotTime > 0, !salah.loc.isEmpty {
            try? await LocalNotifications.shared.scheduleNotification(
                content: AnyNotificationContent(
                    title: "\(salah.name) @\(salah.loc) in 15 mins",
                    body: "حَيَّ عَلَىٰ ٱلْفَلَاحِ",
                    sound: true,
                    badge: nil
                ),
                trigger: .time(timeInterval: salahNotTime, repeats: false)
            )
        }
    }

    var salahLocalDataURL: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let currentMonth = Calendar.current.component(.month, from: Date())
        let currentYear = Calendar.current.component(.year, from: Date())
        let key = "Salah-\(currentMonth)-\(currentYear)"
        return documentsDirectory.appending(path: key)
    }
}
