import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {

    // MARK: - IBOutlets

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!

    // MARK: - Private Properties

    private var presenter: MovieQuizPresenter!

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.layer.cornerRadius = 20

        setupActivityIndicator()
        setupAccessibilityIdentifiers()

        presenter = MovieQuizPresenter(viewController: self)
    }

    // MARK: - IBActions

    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }

    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }

    // MARK: - MovieQuizViewControllerProtocol

    func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }

    func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)

        alert.view.accessibilityIdentifier = "Game results"

        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            guard let self else { return }
            self.presenter.restartGame()
        }

        alert.addAction(action)
        present(alert, animated: true)
    }

    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer
            ? UIColor.ypGreen.cgColor
            : UIColor.ypRed.cgColor
    }

    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }

    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }

    func showNetworkError(message: String) {
        hideLoadingIndicator()

        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert)

        let action = UIAlertAction(title: "Попробовать ещё раз", style: .default) { [weak self] _ in
            guard let self else { return }
            self.presenter.restartGame()
        }

        alert.addAction(action)
        present(alert, animated: true)
    }

    // MARK: - Private Methods

    private func setupActivityIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setupAccessibilityIdentifiers() {
        imageView.accessibilityIdentifier = "Poster"
        counterLabel.accessibilityIdentifier = "Index"
        yesButton.accessibilityIdentifier = "Yes"
        noButton.accessibilityIdentifier = "No"
    }
}
