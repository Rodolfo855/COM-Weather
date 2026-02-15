//
//  Untitled.swift
//  COM Weather
//
//  Created by Victor Rosales  on 2/15/26.
//

import Foundation

// --- MODELS ---
// These match the data structure for your Campus News and Weather stats.

struct FeedItem: Codable {
    let type: String       // "video" or "image"
    let tag: String
    let title: String
    let body: String
    let mediaName: String
    let location: String
}

struct WeatherData: Codable {
    let locationName: String
    let temperature: String
    let humidity: String
    let pressure: String
    let timestamp: String
    let imageName: String
    let detailLocation: String
}

// --- MANAGER ---
// This acts as the "Central Brain" for your app's data.

class FeedDataManager {
    static let shared = FeedDataManager()
    
    // --- LOCAL FALLBACK DATA ---
    // This is what the app shows if the server cannot be reached.
    
    let newsletterFallback: [FeedItem] = [
        FeedItem(type: "video", tag: "STUDENT LIFE", title: "Spring Festival", body: "Buzzing today!", mediaName: "testVideo", location: "Campus Bookstore"),
        FeedItem(type: "image", tag: "ACADEMICS", title: "Library Update", body: "New study pods.", mediaName: "banner1", location: "Fusselman Hall"),
        FeedItem(type: "image", tag: "SPORTS", title: "Soccer Victory", body: "Mariners won!", mediaName: "image5", location: "Athletic Field")
    ]
    
    let weatherFallback: [WeatherData] = [
        WeatherData(locationName: "Kentfield Campus", temperature: "68°F", humidity: "45%", pressure: "1013 hPa", timestamp: "1:30 PM", imageName: "banner1", detailLocation: "Main Quad"),
        WeatherData(locationName: "Indian Valley", temperature: "64°F", humidity: "50%", pressure: "1011 hPa", timestamp: "1:35 PM", imageName: "sunny", detailLocation: "Organic Farm"),
        WeatherData(locationName: "Science Village", temperature: "67°F", humidity: "42%", pressure: "1014 hPa", timestamp: "1:40 PM", imageName: "photo1", detailLocation: "Lab Wing")
    ]
    
    // --- NETWORK METHODS ---
    
    /// Fetches the newsletter feed from the server.
    func fetchFeed(completion: @escaping (Result<[FeedItem], Error>) -> Void) {
        let urlString = "" // <-- Put your future server URL here
        guard let url = URL(string: urlString) else {
            // If no URL is provided, we instantly return a failure to trigger the fallback
            completion(.failure(NSError(domain: "Offline", code: 0, userInfo: [NSLocalizedDescriptionKey: "No URL provided"])))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            
            if let data = data, let items = try? JSONDecoder().decode([FeedItem].self, from: data) {
                DispatchQueue.main.async { completion(.success(items)) }
            } else {
                let parseError = NSError(domain: "DataError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not parse server data"])
                DispatchQueue.main.async { completion(.failure(parseError)) }
            }
        }.resume()
    }
    
    /// Fetches the live weather metrics from the server.
    func fetchWeather(completion: @escaping (Result<[WeatherData], Error>) -> Void) {
        let urlString = "" // <-- Put your future server URL here
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Offline", code: 0, userInfo: [NSLocalizedDescriptionKey: "No URL provided"])))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            
            if let data = data, let items = try? JSONDecoder().decode([WeatherData].self, from: data) {
                DispatchQueue.main.async { completion(.success(items)) }
            } else {
                let parseError = NSError(domain: "DataError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not parse server data"])
                DispatchQueue.main.async { completion(.failure(parseError)) }
            }
        }.resume()
    }
}
