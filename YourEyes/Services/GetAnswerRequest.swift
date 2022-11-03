//
//  GetAnswerRequest.swift
//  YourEyes
//
//  Created by Nguyen Thanh Nhut on 2022/07/10.
//
import UIKit

func getAnAnswer(question: String, imageData: UIImage?, completionHandler: @escaping (MessageResponse?, Error?) -> Void) {
    guard let url = URL(string: "https://9199-125-235-238-57.ngrok.io/model"),
          let imageBase64 = imageData?.toBase64(withPrefix: "data:image/jpeg;base64,")
    else {
        completionHandler(nil, nil)
        return
    }
    
    let params: [String: String] = ["question": question, "image": imageBase64]
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
    
    let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in

        if let error = error {
            print("Error with fetching films: \(error)")
            completionHandler(nil, error)
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            print("Error with the response, unexpected status code: \(response)")
            completionHandler(nil, nil)
            return
        }
        
        print(data, "=============", response)
        
        if let data = data,
           let message = try? JSONDecoder().decode(MessageResponse.self, from: data) {
            print(message)
            completionHandler(message, nil)
        }
    })
    
    task.resume()
}
