import UIKit

final class MovieQuizViewController: UIViewController {
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // берём текущий вопрос из массива вопросов по индексу текущего вопроса
        let currentQuestion = questions[currentQuestionIndex]
        show(quiz: convert(model: currentQuestion))
    }
    // MARK: - IBOutlet
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    
    // MARK: - Structures
    struct QuizQuestion {
        let image: String  // строка с названием фильма
        let text: String // строка с вопросом о рейтинге фильма
        let correctAnswer: Bool  // булевое значение (true, false), правильный ответ на вопрос
    }
    
    // вью модель для состояния "Вопрос показан"
    struct QuizStepViewModel {
      let image: UIImage // картинка с афишей фильма с типом UIImage
      let question: String // вопрос о рейтинге квиза
      let questionNumber: String // строка с порядковым номером этого вопроса (ex. "1/10")
    }
    
    // для состояния "Результат квиза"
    struct QuizResultsViewModel {
      let title: String // строка с заголовком алерта
      let text: String // строка с текстом о количестве набранных очков
      let buttonText: String // текст для кнопки алерта
    }
    
    // MARK: - Private Properties
    private var currentQuestionIndex = 0 // переменная с индексом текущего вопроса, начальное значение 0 (так как индекс в массиве начинается с 0)
    private var correctAnswers = 0 // переменная со счётчиком правильных ответов, начальное значение закономерно 0
    
    // массив вопросов
    private let questions: [QuizQuestion] = [
        QuizQuestion(
            image: "The Godfather",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Dark Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Kill Bill",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Avengers",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Deadpool",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Green Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Old",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "The Ice Age Adventures of Buck Wild",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "Tesla",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "Vivarium",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false)
    ]
    
    // MARK: - IBAction
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        let currentQuestion = questions[currentQuestionIndex]
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        let currentQuestion = questions[currentQuestionIndex]
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    // MARK: - Private Methods
    
    // метод конвертации, который принимает моковый вопрос и возвращает вью модель для экрана вопроса
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
                image: UIImage(named: model.image) ?? UIImage(),
                question: model.text,
                questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)")
            return questionStep
    }
    
    // приватный метод вывода на экран вопроса, который принимает на вход вью модель вопроса и ничего не возвращает
    private func show(quiz step: QuizStepViewModel) {
          imageView.image = step.image
          textLabel.text = step.question
          counterLabel.text = step.questionNumber
    }
    
    // приватный метод, который меняет цвет рамки
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1 //Увеличиваем счётчик количества правильных ответов
        }
        
        imageView.layer.masksToBounds = true // даём разрешение на рисование рамки
        imageView.layer.borderWidth = 8 // толщина рамки
        if isCorrect {
            imageView.layer.borderColor = UIColor.ypGreen.cgColor // делаем рамку green
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor // делаем рамку red
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // запускаем задачу через 1 секунду c помощью диспетчера задач
           self.showNextQuestionOrResults() // код, который мы хотим вызвать через 1 секунду
        }
    }
    
    // приватный метод для показа результатов раунда квиза
    // принимает вью модель QuizResultsViewModel и ничего не возвращает
    private func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        
        // константа с кнопкой для системного алерта
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
          // код, который сбрасывает игру и показывает первый вопрос
            self.currentQuestionIndex = 0 // сбрасываем индекс текущего вопроса до 0
            self.correctAnswers = 0 // сбрасываем переменную с количеством правильных ответов
            let firstQuestion = self.questions[self.currentQuestionIndex] // находим первый вопрос
            let viewModel = self.convert(model: firstQuestion) // конвертируем вопрос
            self.show(quiz: viewModel) // отображаем данные из вью модели на экране
        }
        
        alert.addAction(action)

        self.present(alert, animated: true, completion: nil)
    }
    
    // приватный метод, который содержит логику перехода в один из сценариев
    // метод ничего не принимает и ничего не возвращает
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questions.count - 1 { // Сравниваем номер текущего вопроса с размером массива моковых вопросов -1
            // идём в состояние "Результат квиза"
            let results = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: "Ваш результат: \(correctAnswers) /\(currentQuestionIndex + 1)",
                buttonText: "Сыграть ещё раз")
            show(quiz: results)
            
        } else { // Показываем новый вопрос
            currentQuestionIndex += 1
            let nextQuestion = questions[currentQuestionIndex] // переходим на следующий вопрос в массиве
            let viewModel = convert(model: nextQuestion) // конвертируем вопрос
            show(quiz: viewModel) // показываем вопрос
        }
    }
}
