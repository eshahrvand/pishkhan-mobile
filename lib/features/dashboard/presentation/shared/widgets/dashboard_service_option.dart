import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';

import '../dashboard_services.dart';

class DashboardServiceOption extends StatelessWidget {
  const DashboardServiceOption({
    super.key,
    required this.service,
    required this.enabled,
    required this.onSelected,
    this.plain = false,
  });
  final DashboardService service;
  final bool enabled;
  final ValueChanged<DashboardService> onSelected;
  final bool plain;
  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: service.catalogLabel(),
      child: Opacity(
        opacity: enabled ? 1 : .45,
        child: Material(
          color: plain ? Colors.transparent : AppDashboardColors.tileSurface,
          borderRadius: AppRadius.borderMd,
          child: InkWell(
            onTap: enabled ? () => onSelected(service) : null,
            borderRadius: AppRadius.borderMd,
            child: Container(
              constraints: BoxConstraints(minHeight: plain ? 20 : 40),
              padding: plain
                  ? EdgeInsets.zero
                  : const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: plain
                  ? null
                  : BoxDecoration(
                      border: Border.all(
                        color: context.colors.border,
                        width: .8,
                      ),
                      borderRadius: AppRadius.borderMd,
                    ),
              child: Row(
                children: [
                  AvpImage(image: service.optionAsset),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      service.catalogLabel(),
                      style: AppTypography.bodySmall.copyWith(
                        color: plain
                            ? context.colors.textPrimary
                            : AppDashboardColors.optionText,
                        fontWeight: FontWeight.w500,
                        height: 18 / 12,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
