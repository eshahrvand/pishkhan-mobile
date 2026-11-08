# Change wallet linked deposit

Status: implemented against an in-memory demo adapter; no live wallet API is configured.

- Feature: `lib/features/wallet`; flow: `presentation/linked_deposit`.
- Service ID: `wallet-deposit`; route: `/wallet/linked-deposit`.
- Boundary: screen-owned Cubit → registered operation UseCase → `WalletRepository`.
- Rules: [UI/Cubit/State contract](../ui-cubit-state-agent-rules-en.md).

## Design references

- [Frame 28201-88660](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-%7C-Mobile?node-id=28201-88660&m=dev)
- [Frame 28201-89012](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-%7C-Mobile?node-id=28201-89012&m=dev)
- [Frame 28201-89035](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-%7C-Mobile?node-id=28201-89035&m=dev)

## Flow and operation ownership

Show the current linked deposit → choose another eligible deposit → read and accept terms → confirm → localized success and return. The current deposit is excluded from destination choices. Acceptance and selection are independent State fields; both are required to enable confirmation.

| Operation | Owner | Triggers |
|---|---|---|
| Catalog / eligible deposits / terms | `fetchCatalog` | Provider entry, retry |
| Change link | `submitChange` | Confirm button |

Existing `CertificateInput`, typed `CertificateSelect<WalletDeposit>`, `AppCheckbox`, shared modal launcher and header are reused. Terms open on the root navigator with reachable scrollable content. The CTA label follows the supplied design; the mock does not invent a fee or charge for changing a link. No payment receipt was supplied for this flow, so successful change returns to its entry rather than fabricating another receipt design.

The submit key survives failure/retry and changes when the selected deposit changes. During submission the selection, acceptance, terms and Back actions are gated. Returning to wallet overview triggers its catalog refresh so the newly linked deposit appears immediately. The success notification uses the root-overlay `avpSnackBar` and remains visible after returning.

Eligible deposits and terms are demo data. The text is derived from the supplied design and explicitly marked as a sample; current bank-approved legal copy, eligibility, fee and authorization must be supplied by the real service. Other deposit features are not mutated by this mock.

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
