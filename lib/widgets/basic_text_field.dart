import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AppInputTextField extends StatelessWidget {
  final String label;
  final TextInputType textInputType;
  final IconData? iconData;
  final IconData? endIcon;
  final bool showLabel;
  final bool isObscure;
  final GestureTapCallback? onEndIconTap;
  final TextEditingController? controller;
  final List<String>? hint;
  final String? hintText;
  final bool enable;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int? maxLength;

  /// 🔽 Dropdown related
  final bool isDropdown;
  final List<String>? dropdownItems;
  final ValueChanged<String>? onDropdownChanged;

  const AppInputTextField({
    super.key,
    this.label = "Input Label",
    this.iconData,
    this.controller,
    this.endIcon,
    this.hint,
    this.onEndIconTap,
    this.validator,
    this.onChanged,
    this.hintText,
    this.inputFormatters,
    this.showLabel = true,
    this.isObscure = false,
    this.enable = true,
    this.textInputType = TextInputType.text,

    /// Dropdown
    this.isDropdown = false,
    this.dropdownItems,
    this.onDropdownChanged,
    this.maxLength,
  }) : assert(
         isDropdown == false || dropdownItems != null,
         'dropdownItems must be provided when isDropdown is true',
       );

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        if (showLabel) ...[Text(label, style: theme.textTheme.labelMedium)],

        TextFormField(
          controller: controller,
          enabled: enable,
          readOnly: isDropdown,
          canRequestFocus: !isDropdown && enable,
          obscureText: isObscure,
          keyboardType: textInputType,
          autofillHints: hint,
          maxLength: maxLength,
          onTapOutside: (_) => FocusScope.of(context).unfocus(),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: validator,
          inputFormatters: isDropdown ? null : inputFormatters,
          onChanged: isDropdown ? null : onChanged,

          /// 🔽 Handle tap for dropdown
          onTap: isDropdown ? () => _showDropdown(context) : null,

          decoration: InputDecoration(
            hintText: hintText ?? "Your ${label.toLowerCase()}",
            hintStyle: context.textTheme.bodyMedium,

            prefixIcon: iconData == null ? null : Icon(iconData, size: 20),

            suffixIcon: isDropdown
                ? Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: theme.primaryColor,
                  )
                : endIcon == null
                ? null
                : IconButton(
                    onPressed: onEndIconTap,
                    style: IconButton.styleFrom(side: BorderSide.none),
                    icon: Icon(endIcon, color: theme.primaryColor),
                  ),
          ),
        ),
      ],
    );
  }

  /// 🔽 Dropdown bottom sheet
  void _showDropdown(BuildContext context) {
    FocusScope.of(context).unfocus();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: dropdownItems!.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final item = dropdownItems![index];
            return ListTile(
              title: Text(item),
              onTap: () {
                controller?.text = item;
                onDropdownChanged?.call(item);
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }
}

class BirthdayDateField extends StatefulWidget {
  const BirthdayDateField({super.key});

  @override
  State<BirthdayDateField> createState() => _BirthdayDateFieldState();
}

class _BirthdayDateFieldState extends State<BirthdayDateField> {
  final TextEditingController dayCtrl = TextEditingController();
  final TextEditingController monthCtrl = TextEditingController();
  final TextEditingController yearCtrl = TextEditingController();

  final FocusNode dayFocus = FocusNode();
  final FocusNode monthFocus = FocusNode();
  final FocusNode yearFocus = FocusNode();

  @override
  void dispose() {
    dayCtrl.dispose();
    monthCtrl.dispose();
    yearCtrl.dispose();
    dayFocus.dispose();
    monthFocus.dispose();
    yearFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: dayCtrl,
            focusNode: dayFocus,
            textAlign: TextAlign.start,
            style: context.textTheme.headlineSmall,
            keyboardType: TextInputType.number,
            maxLength: 2,
            decoration: InputDecoration(
              filled: false,
              counterText: "",
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              hintText: 'DD',
              hintStyle: context.textTheme.headlineSmall?.copyWith(
                color: context.textTheme.bodySmall?.color,
                fontWeight: FontWeight.w800,
              ),
            ),
            onChanged: (value) {
              if (value.length == 2) monthFocus.requestFocus();
            },
          ),
        ),

        Container(height: 35, width: 1, color: context.theme.dividerColor),

        // --------------------- MM ---------------------
        Expanded(
          child: TextField(
            controller: monthCtrl,
            focusNode: monthFocus,
            textAlign: TextAlign.start,
            style: context.textTheme.headlineSmall,
            keyboardType: TextInputType.number,
            maxLength: 2,
            decoration: InputDecoration(
              filled: false,
              counterText: "",
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              hintText: 'MM',
              hintStyle: context.textTheme.headlineSmall?.copyWith(
                color: context.textTheme.bodySmall?.color,
                fontWeight: FontWeight.w800,
              ),
            ),
            onChanged: (value) {
              if (value.length == 2) {
                yearFocus.requestFocus();
              } else if (value.isEmpty) {
                dayFocus.requestFocus();
              }
            },
          ),
        ),

        Container(height: 35, width: 1, color: context.theme.dividerColor),

        // --------------------- YYYY ---------------------
        Expanded(
          child: TextField(
            controller: yearCtrl,
            focusNode: yearFocus,
            textAlign: TextAlign.start,
            style: context.textTheme.headlineSmall,
            keyboardType: TextInputType.number,
            maxLength: 4,
            decoration: InputDecoration(
              filled: false,
              counterText: "",
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              hintText: 'YYYY',
              hintStyle: context.textTheme.headlineSmall?.copyWith(
                color: context.textTheme.bodySmall?.color,
                fontWeight: FontWeight.w800,
              ),
            ),
            onChanged: (value) {
              if (value.isEmpty) {
                monthFocus.requestFocus();
              }
            },
          ),
        ),
      ],
    );
  }
}
