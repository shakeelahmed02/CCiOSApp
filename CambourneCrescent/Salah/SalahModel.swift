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
