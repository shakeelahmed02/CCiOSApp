//
//  SalahModel.swift
//  CambourneCrescent
//
//  Created by Ahmed, Shakeel on 27/07/2024.
//

import Foundation

struct SalahAPIResponse: Codable {
    let day: String
    let date: String
    let namaz: [SalahModel]
}

struct SalahModel: Codable {
    let start: String
    let jamat: String
    let loc: String
    let sun: String
    let name: String
}

extension SalahModel {
    func salahName(day: String) -> String {
        switch name.lowercased() {
        case "fajr":
            return "Fajr"
        case "dhohr":
            return day.lowercased() == "fri" ? "Jummah" : "Dhuhr"
        case "asr":
            return "Asr"
        case "magrib":
            return "Maghrib"
        case "isha":
            return "Isha"
        default:
            return "Salah"
        }
    }
}
