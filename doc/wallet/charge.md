# Wallet charge

Status: implemented against an in-memory demo adapter; no live wallet API is configured.

- Feature: `lib/features/wallet`; flow: `presentation/charge`.
- Service ID: `wallet-charge`; route: `/wallet/charge`.
- Boundary: screen-owned Cubit → registered operation UseCase → `WalletRepository`.
- Rules: [UI/Cubit/State contract](../ui-cubit-state-agent-rules-en.md).

## Design references

- [Frame 28201-88431](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-%7C-Mobile?node-id=28201-88431&m=dev)
- [Frame 28201-89227](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-%7C-Mobile?node-id=28201-89227&m=dev)
- [Frame 28201-89303](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-%7C-Mobile?node-id=28201-89303&m=dev)
- [Frame 28201-89379](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-%7C-Mobile?node-id=28201-89379&m=dev)
- [Frame 28245-83181](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-%7C-Mobile?node-id=28245-83181&m=dev)

## Flow and operation ownership

Enter an integer rial amount → request dynamic password → enter the code → confirm payment → receipt. Empty/filled/resend screens are states of the same flow. The receipt replaces the form within the current route, so Back cannot expose a successfully submitted form. Copy and platform share use the returned receipt, including its tracking number, timestamp and resulting balance.

| Operation | Owner | Triggers |
|---|---|---|
| Wallet fetch | `fetchWallet` | Provider entry, retry |
| OTP request / resend | `requestOtp` | Request/resend button |
| Charge | `submitPayment` | Confirm button |

The amount is validated once when edited. The OTP validator uses the challenge's code length. The deadline and length are returned by the service; Cubit owns and cancels its timer. Editing an amount invalidates the amount-bound challenge and visible OTP. Expiry disables payment and enables resend. Resend clears the displayed old code because it belongs to the previous challenge.

The submit key survives failure/retry. A lost response after the demo ledger commits does not credit twice. Only editing the payment creates a new identity. Pending submission blocks Back, editing and resend; the secondary control does not show the payment spinner. Failure retains entered data; repeated identical errors notify through operation status transitions.

The demo code is **2345**, valid for **60 seconds**. These are mock response values, not production bank policies. No bank account is debited. An actual funding/authorization API and its limits are still required.

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
