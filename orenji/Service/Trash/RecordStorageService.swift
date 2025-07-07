//
//  RecordStorageService.swift
//  orenji
//
//  Created by Muhamad Alif Anwar on 20/06/25.
//

import Foundation
//jadi yang ini untuk menyimpan dalam bentuk json ke storage
protocol RecordStorageService {
    func saveAnalysisRecord(_ record: RecordAnalysisModel) throws
    func loadAllRecords() throws -> [RecordAnalysisModel]
}
