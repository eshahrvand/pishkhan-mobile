# Wallet-to-wallet transfer

Status: implemented against an in-memory demo adapter; no live wallet API is configured.

- Feature: `lib/features/wallet`; flow: `presentation/transfer`.
- Service ID: `wallet-transfer`; route: `/wallet/transfer`.
- Boundary: screen-owned Cubit → registered operation UseCase → `WalletRepository`.
- Rules: [UI/Cubit/State contract](../ui-cubit-state-agent-rules-en.md).

## Design references

- [Frame 28201-88585](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-%7C-Mobile?node-id=28201-88585&m=dev)
- [Frame 28201-89068](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-%7C-Mobile?node-id=28201-89068&m=dev)
- [Frame 28243-82891](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-%7C-Mobile?node-id=28243-82891&m=dev)

## Flow and operation ownership

Enter the destination wallet/mobile identifier → resolve its owner → enter an amount within wallet balance → confirm transfer → receipt. The supplied transfer designs contain withdrawal/charge titles and receipt copy; authored text consistently identifies transfer and the destination wallet.

| Operation | Owner | Triggers |
|---|---|---|
| Wallet fetch | `fetchWallet` | Provider entry, retry |
| Recipient inquiry | `inquireRecipient` | Valid destination after 350ms debounce, inquiry retry |
| Transfer | `submitTransfer` | Confirm button |

An edit immediately removes the old owner and disables submit. A request ID invalidates an earlier inquiry response even before the next debounced request starts. Only a resolved owner and a valid amount enable transfer. The debounce timer is cancelled when inquiry starts and when Cubit closes. Form actions receive the resolved recipient object from State; no UI lookup chooses the next action.

Known demo recipients are `09126024179` / wallet `10000001` (مهسا جوانمرد), and `09121111111` / wallet `10000002` (علی رضایی). Arbitrary identifiers do not acquire a fabricated owner; self transfer is rejected. These are isolated fixtures, not a real inquiry service. The demo debits only this wallet's in-memory ledger; it does not contact or credit a real recipient account.

The key survives retry. The repository checks current funds at commit. The receipt replaces the form and shares its actual returned data. There is no OTP step in the supplied transfer designs; production authorization requirements remain an API integration decision.

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
