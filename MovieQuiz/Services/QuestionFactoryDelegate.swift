//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)   
    func didLoadDataFromServer() // сообщение об успешной загрузке
    func didFailToLoadData(with error: Error) // сообщение об ошибке загрузки
    func didFailToReceiveNextQuestion(with error: Error)
    func didLoadEmptyData(errorMessage: String)
}
