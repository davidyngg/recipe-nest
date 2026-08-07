//
//  TimersViewController.swift
//
//
//  Created by Noah Sellers on 7/31/26.
//

import UIKit

class TimersViewController: UIViewController {

    private let store = TimerStore.shared
    private var timers: [RecipeTimer] = []
    private var tickTimer: Timer?

    private let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Timers"
        view.backgroundColor = .systemBackground

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))

        tableView.register(TimerCell.self, forCellReuseIdentifier: "TimerCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 76
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reload()
        startTicking()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tickTimer?.invalidate()
        tickTimer = nil
    }

    private func reload() {
        timers = store.timers
        tableView.reloadData()
    }

    private func startTicking() {
        tickTimer?.invalidate()
        tickTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    private func tick() {
        var didFinishAny = false
        for (index, timer) in timers.enumerated() where timer.isRunning {
            if timer.displayRemaining <= 0 {
                timers[index].endDate = nil
                timers[index].remaining = 0
                store.update(timers[index])
                didFinishAny = true
            }
        }

        if didFinishAny {
            tableView.reloadData()
            return
        }

        for indexPath in tableView.indexPathsForVisibleRows ?? [] {
            guard indexPath.row < timers.count,
                  let cell = tableView.cellForRow(at: indexPath) as? TimerCell else { continue }
            cell.updateTimeLabel(remaining: timers[indexPath.row].displayRemaining)
        }
    }

    private func openEditor(for timer: RecipeTimer?) {
        let editor = AddEditTimerViewController(timer: timer)
        editor.onSave = { [weak self] in self?.reload() }
        navigationController?.pushViewController(editor, animated: true)
    }

    @objc private func addTapped() {
        openEditor(for: nil)
    }
}

// MARK: - UITableViewDataSource / Delegate

extension TimersViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        timers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TimerCell", for: indexPath) as! TimerCell
        cell.delegate = self
        cell.configure(with: timers[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        openEditor(for: timers[indexPath.row])
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        let timer = timers[indexPath.row]
        store.delete(timer)
        timers.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}

// MARK: - TimerCellDelegate

extension TimersViewController: TimerCellDelegate {

    func timerCellDidToggle(_ cell: TimerCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        var timer = timers[indexPath.row]
        if timer.isRunning {
            timer.pause()
        } else {
            if timer.remaining <= 0 {
                timer.remaining = timer.duration
            }
            timer.start()
        }
        timers[indexPath.row] = timer
        store.update(timer)
        tableView.reloadRows(at: [indexPath], with: .none)
    }

    func timerCellDidReset(_ cell: TimerCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        var timer = timers[indexPath.row]
        timer.reset()
        timers[indexPath.row] = timer
        store.update(timer)
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}
