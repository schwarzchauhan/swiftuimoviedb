//
//  MovieStore.swift
//  swiftuimoviedb
//
//  Created by Harsh Chauhan on 11/3/26.
//


import Foundation

class MovieStore: MovieService {
   
    static let shared = MovieStore()
    private init() {
        
    }
    
    
    private let apiKey = "246603c4b2b87b753d8e71f14aee26c7"
    private let baseURL = "https://api.themoviedb.org/3"
    private let urlSessioon = URLSession.shared
    private let jsonDecoder = Utils.jsonDecoder
    
    
    // https://developer.themoviedb.org/reference/movie-now-playing-list
    // https://developer.themoviedb.org/reference/movie-popular-list
    // https://developer.themoviedb.org/reference/movie-top-rated-list
    // https://developer.themoviedb.org/reference/movie-upcoming-list
    func fetchMovies(from endpoint: MovieListEndPoint, completion: @escaping (Result<[Movie], MovieError>) -> ()) {
        guard let url = URL(string: "\(baseURL)/movies/\(endpoint.rawValue)") else {
            completion(.failure(.invalidEndpoint))
            return
        }
        self.loadUrlAndDecode(url: url,
                              params: ["append_to_response": "videos,credits"],
                              completion: completion)
    }
    
    // https://developer.themoviedb.org/reference/movie-details
    func fetchMovie(id: Int, completion: @escaping (Result<Movie, MovieError>) -> ()) {
        guard let url = URL(string: "\(baseURL)/movies/\(id)") else {
            completion(.failure(.invalidEndpoint))
            return
        }
        // https://developer.themoviedb.org/docs/append-to-response

        self.loadUrlAndDecode(url: url, completion: completion)
    }
    
    // https://developer.themoviedb.org/reference/search-movie
    func searchMovie(query: String, completion: @escaping (Result<MovieResponse, MovieError>) -> ()) {
        guard let url = URL(string: "\(baseURL)/search/movie") else {
            completion(.failure(.invalidEndpoint))
            return
        }
        self.loadUrlAndDecode(url: url,
                              params: [
                                "language": "en-US",
                                "include_adult": "false",
                                "region": "US",
                                "query": query
                              ],
                              completion: completion)
    }
    
    private func loadUrlAndDecode<T: Decodable>(url: URL, params: [String: String]? = nil, completion: @escaping (Result<T, MovieError>) -> ()) {
        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            completion(.failure(.invalidEndpoint))
            return
        }
        var queryItems = [URLQueryItem(name: "api_key", value: apiKey)]
        if let params = params {
            queryItems.append(contentsOf: params.map({ URLQueryItem(name: $0.key, value: $0.value)  }))
        }
        
        urlComponents.queryItems = queryItems
        
        guard let finalUrl = urlComponents.url else {
            completion(.failure(.invalidEndpoint))
            return
        }
        
        urlSessioon.dataTask(with: finalUrl)  { [weak self] (data, response, error) in
            guard let self else { return }
            if error != nil {
                self.executeCompletionHandlerInMainThread(with: .failure(.apiError), completion: completion)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200..<300) ~= httpResponse.statusCode else {
                self.executeCompletionHandlerInMainThread(with: .failure(.invalidResponse), completion: completion)
                return
            }
            
            guard let data = data else {
                self.executeCompletionHandlerInMainThread(with: .failure(.noData), completion: completion)
                return
            }
            
            do {
                let decodedResponse = try self.jsonDecoder.decode(T.self, from: data)
                self.executeCompletionHandlerInMainThread(with: .success(decodedResponse), completion: completion)
            } catch {
                self.executeCompletionHandlerInMainThread(with: .failure(.serializationError), completion: completion)
            }
            
        }.resume()
    }
    
    private func executeCompletionHandlerInMainThread<D: Decodable>(with result: Result<D,MovieError>, completion: @escaping (Result<D,MovieError>) -> ()) {
        DispatchQueue.main.async {
            completion(result)
        }
    }
    
}


