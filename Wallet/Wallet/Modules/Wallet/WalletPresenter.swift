import Foundation
import WalletKit
import RealmSwift

class WalletPresenter {

    let interactor: IWalletInteractor
    let router: IWalletRouter
    weak var view: IWalletView?

    var walletBalances = [WalletBalanceItem]()

    init(interactor: IWalletInteractor, router: IWalletRouter) {
        self.interactor = interactor
        self.router = router
    }

}

extension WalletPresenter: IWalletInteractorDelegate {

    func didFetch(walletBalances: [WalletBalanceItem]) {
        self.walletBalances = walletBalances

        var totalBalance: Double = 0
        var viewItems = [WalletBalanceViewItem]()

        for balance in walletBalances {
            totalBalance += balance.coinValue.value * balance.exchangeRate
            viewItems.append(viewItem(forBalance: balance))
        }

        if let currency = walletBalances.first?.currency {
            view?.show(totalBalance: CurrencyValue(currency: currency, value: totalBalance))
        }

        view?.show(walletBalances: viewItems)
    }

    func didUpdate(syncStatus: WalletKit.SyncManager.SyncStatus) {
        view?.show(syncStatus: String(describing: syncStatus))
    }

    private func viewItem(forBalance balance: WalletBalanceItem) -> WalletBalanceViewItem {
        return WalletBalanceViewItem(
                coinValue: balance.coinValue,
                exchangeValue: CurrencyValue(currency: balance.currency, value: balance.exchangeRate),
                currencyValue: CurrencyValue(currency: balance.currency, value: balance.coinValue.value * balance.exchangeRate)
        )
    }

}

extension WalletPresenter: IWalletViewDelegate {

    func viewDidLoad() {
        interactor.notifyWalletBalances()
    }

    func refresh() {
        let realm = try! Realm()
        let count = realm.objects(Block.self).count

        print("BLOCK COUNT: \(count)")

        for block in realm.objects(Block.self) {
            print("\(block.height) --- \(block.reversedHeaderHashHex)")
        }
    }

    func onReceive(for index: Int) {
        if index < walletBalances.count {
            router.onReceive(for: walletBalances[index])
        } else {
            print("open stab wallet deposit")
            //test stab

        }
    }

}
