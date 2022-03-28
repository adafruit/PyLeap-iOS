//
//  NetworkError.swift
//  PyLeap
//
//  Created by Trevor Beaton on 3/10/22.
//


import Foundation

enum NetworkError: String, Error {
    
    case noInternetConnection = "There's a problem with your internet connection. Try again later."
    case invalidURL = "Invalid URL used. Please update URL and try again."
    case unableToCompleteRequest = "Unable to complete request. Check your internet connection and try again."
    case invalidResponse = "Invalid response from the server.Please try again."
    case invalidData = "Invalid data was received. Please try again."
    case noDataAvailable = "Data not available."
}
