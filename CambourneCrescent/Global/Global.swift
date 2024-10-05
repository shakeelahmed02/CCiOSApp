//
//  Global.swift
//  CambourneCrescent
//
//  Created by Ahmed, Shakeel on 10/08/2024.
//

import Foundation

struct Global {
    static var shared = Global()
    private init() {}
    
    var soundOn: Bool {
        set {
            UserDefaults.standard.setValue(newValue, forKey: "NOTIFICATION-SOUNDS-ON")
            UserDefaults.standard.synchronize()
        }
        get {
            UserDefaults.standard.bool(forKey: "NOTIFICATION-SOUNDS-ON")
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
    
    func getSalahTimings() async -> [SalahAPIResponse] {
        guard let data = try? Data(contentsOf: Global.shared.salahLocalDataURL) else {
            print("Salah local data not available")
            return await getSalahTimingsFromRemote()
        }
        return decodeSalahData(data: data)
    }
    
    private func getSalahTimingsFromRemote() async -> [SalahAPIResponse] {
        let salahAPIURL = URL(string: "https://cambournecrescent.org/salah/index-app-json.php")!
        guard let data = try? await URLSession.shared.data(for: URLRequest(url: salahAPIURL)).0 else {
            print("SalahAPI not working")
            return []
        }
        try? data.write(to: Global.shared.salahLocalDataURL, options: .atomic)
        return decodeSalahData(data: data)
    }
    
    private func decodeSalahData(data: Data) -> [SalahAPIResponse] {
        guard let salahs = try? JSONDecoder().decode([SalahAPIResponse].self, from: data) else {
            print("Could not decode data")
            return []
        }
        return salahs.filter { model in
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
}
