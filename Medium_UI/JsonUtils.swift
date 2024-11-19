//
//  JsonUtils.swift
//  Medium_UI
//
//  Created by shahanul on 11/18/24.
//

import Foundation

final class JsonUtils {
    static func getJsonData() -> MediumPostResponse? {
        guard let path = Bundle.main.path(forResource: "dummy", ofType: "json") else {
            print("JSON file not found in bundle")
            return nil
        }
        
        do {
            let jsonData = try Data(contentsOf: URL(fileURLWithPath: path))
            let decoder = JSONDecoder()
            return try decoder.decode(MediumPostResponse.self, from: jsonData)
        } catch {
            print("Error: \(error)")
            return nil
        }
    }
}
