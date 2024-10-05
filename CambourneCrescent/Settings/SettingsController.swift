//
//  SettingsController.swift
//  CambourneCrescent
//
//  Created by Ahmed, Shakeel on 27/07/2024.
//

import UIKit

class SettingsController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.title = "Settings"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath)
        (cell.viewWithTag(1) as? UILabel)?.text = "Sounds"
        (cell.viewWithTag(2) as? UISwitch)?.isOn = Global.shared.soundOn
        (cell.viewWithTag(2) as? UISwitch)?.addTarget(self, action: #selector(soundSwitchAction(sender:)), for: .valueChanged)
        return cell
    }

    @objc func soundSwitchAction(sender: UISwitch) {
        Global.shared.soundOn = sender.isOn
        Task {
            await LocalNotifications.shared.scheduleNotificaitons()
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
