# Wallet withdrawal

Status: implemented against an in-memory demo adapter; no live wallet API is configured.

- Feature: `lib/features/wallet`; flow: `presentation/withdraw`.
- Service ID: `wallet-withdraw`; route: `/wallet/withdraw`.
- Boundary: screen-owned Cubit → registered operation UseCase → `WalletRepository`.
- Rules: [UI/Cubit/State contract](../ui-cubit-state-agent-rules-en.md).

## Design references

- [Frame 28201-88508](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-%7C-Mobile?node-id=28201-88508&m=dev)
- [Frame 28201-89151](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-%7C-Mobile?node-id=28201-89151&m=dev)
- [Frame 28245-83017](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-%7C-Mobile?node-id=28245-83017&m=dev)

## Flow and operation ownership

Enter a rial amount within the fetched wallet balance → request dynamic password → enter the code → confirm → withdrawal receipt. This flow owns a separate State, request statuses, challenge and timer from charge. The same presentation-only amount, OTP, balance and receipt widgets are composed by its explicit form.

| Operation | Owner | Triggers |
|---|---|---|
| Wallet fetch | `fetchWallet` | Provider entry, retry |
| Withdrawal OTP / resend | `requestOtp` | Request/resend button |
| Withdrawal | `submitPayment` | Confirm button |

Withdrawal targets the linked deposit returned in the wallet summary, rather than an arbitrary destination. Form validation reads the fetched balance and the repository rechecks its actual ledger balance at commit. OTP challenges are bound to the operation and amount, so a charge challenge cannot authorize withdrawal. The balance shown in the receipt is the returned resulting balance.

Amount edits invalidate the old challenge; expiry enables resend. The timer is disposed with Cubit. A pending submit gates editing, Back and secondary actions. Retry retains the request identity and the receipt replaces the form, preventing return to a submitted form.

Demo OTP **2345**, validity **60 seconds**. Only an in-memory wallet balance changes; no actual deposit is credited. Bank payout eligibility, final limits and transaction authorization must come from the production API.

## Verification

Behavioral coverage is in `test/wallet/wallet_cubit_test.dart` and
`test/wallet/wallet_screen_test.dart`. Run the changed feature only:

```sh
flutter test --no-pub test/wallet
```

The overview document lists the directly related shared regression scope.
All request failures publish the operation status, Failure and prepared message
together. Old failure text is retained across loading/success and never suppresses
an independent navigation or share effect. Buttons pass operation loading through
`isLoading` and enablement through `isActive`, with directly bound callbacks.
