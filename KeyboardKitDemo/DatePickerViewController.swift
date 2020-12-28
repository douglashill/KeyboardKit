// Douglas Hill, December 2020

import UIKit
import KeyboardKit

class DatePickerViewController: FirstResponderViewController {
    override init() {
        super.init()
        title = "Date Picker"
        tabBarItem.image = UIImage(systemName: "calendar")
    }

    private lazy var datePicker = KeyboardDatePicker()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        view.addSubview(datePicker)

        datePicker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            datePicker.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            datePicker.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            datePicker.widthAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.widthAnchor),
            datePicker.heightAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.heightAnchor),
        ])

        datePicker.preferredDatePickerStyle = .inline
        datePicker.datePickerMode = .date
        datePicker.minimumDate = datePicker.calendar.date(byAdding: .year, value: -5, to: datePicker.date)
        datePicker.maximumDate = datePicker.calendar.date(byAdding: .year, value: +5, to: datePicker.date)
    }

    override var kd_preferredFirstResponderInHierarchy: UIResponder? {
        presentedViewController ?? datePicker
    }
}
