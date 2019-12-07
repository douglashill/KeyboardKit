// Douglas Hill, December 2019

import UIKit
import KeyboardKit

class TextViewController: UIViewController {
    override var title: String? {
        get { "Text View" }
        set {}
    }

    lazy private var textView = KeyboardTextView()

    override func loadView() {
        view = textView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        textView.font = UIFont.preferredFont(forTextStyle: .title1)

        textView.text = """
        Hic culpa nam vel expedita neque voluptatem ducimus. Quis aspernatur sunt natus neque amet quibusdam blanditiis magni. Nisi perferendis quam maiores et non dolorem. Delectus minima dolore iste.

        Vero inventore commodi eligendi nihil voluptas fuga. Qui facilis neque qui est suscipit earum et. Qui sit nisi qui nihil nobis.

        Et temporibus dolores aliquam laboriosam dolorum ipsa. Est veniam quidem voluptates aut non debitis excepturi. Fuga fugit ducimus eaque. Assumenda asperiores enim impedit amet. Suscipit eos cum et quis. Placeat quam inventore odit occaecati deserunt perspiciatis facilis.

        Et rerum voluptatem quo ea ut incidunt quos. Veritatis reiciendis architecto laborum est deleniti. Nostrum eius aut eum modi et aut voluptates. Ut in velit minus quia et. Quia saepe et eos a porro ad pariatur.

        Ipsa et et omnis blanditiis aliquid necessitatibus similique sint. Illo ipsam et ratione repudiandae eos temporibus aut explicabo. Nemo repudiandae vitae vitae a enim exercitationem delectus. Consequatur alias et rem dolorem recusandae.

        Hic culpa nam vel expedita neque voluptatem ducimus. Quis aspernatur sunt natus neque amet quibusdam blanditiis magni. Nisi perferendis quam maiores et non dolorem. Delectus minima dolore iste.

        Vero inventore commodi eligendi nihil voluptas fuga. Qui facilis neque qui est suscipit earum et. Qui sit nisi qui nihil nobis.

        Et temporibus dolores aliquam laboriosam dolorum ipsa. Est veniam quidem voluptates aut non debitis excepturi. Fuga fugit ducimus eaque. Assumenda asperiores enim impedit amet. Suscipit eos cum et quis. Placeat quam inventore odit occaecati deserunt perspiciatis facilis.

        Et rerum voluptatem quo ea ut incidunt quos. Veritatis reiciendis architecto laborum est deleniti. Nostrum eius aut eum modi et aut voluptates. Ut in velit minus quia et. Quia saepe et eos a porro ad pariatur.

        Ipsa et et omnis blanditiis aliquid necessitatibus similique sint. Illo ipsam et ratione repudiandae eos temporibus aut explicabo. Nemo repudiandae vitae vitae a enim exercitationem delectus. Consequatur alias et rem dolorem recusandae.
        """
    }
}
