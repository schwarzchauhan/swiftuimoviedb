//
//  MovieService.swift
//  swiftuimoviedb
//
//  Created by Harsh Chauhan on 11/2/26.
//

import Foundation

protocol MovieService {
    func fetchMovies(from endpoint: MovieListEndPoint, completion: @escaping (Result<[Movie], MovieError>) -> ())
    func fetchMovie(id: Int, completion: @escaping (Result<Movie, MovieError>) -> ())
    func searchMovie(query: String, completion: @escaping (Result<MovieResponse, MovieError>) -> ())
}


enum MovieListEndPoint: String {
    case nowPlaying = "now_playing"
    case topRated = "top_rated"
    case upcoming = "upcoming"
    case popular = "popular"
    
    var description: String {
        switch self {
        case .nowPlaying:
            return "Now Playing"
        case .topRated:
            return "Top Rated"
        case .upcoming:
            return "Upcoming"
        case .popular:
            return "Popular"
        }
    }
}

enum MovieError: Error, CustomNSError {
    case apiError
    case invalidEndpoint
    case noData
    case invalidResponse
    case serializationError
    
    var localizedDescription: String {
        switch self {
        case .apiError:
            return "API Error"
        case .invalidEndpoint:
            return "Invalid Endpoint"
        case .noData:
            return "No Data"
        case .invalidResponse:
            return "Invalid Response"
        case .serializationError:
            return "Serialization Error"
        }
    }
    
    var errorUserInfo: [String : Any] {
        [NSLocalizedDescriptionKey: localizedDescription]
    }
}

