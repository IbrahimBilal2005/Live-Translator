import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';

class SurahDropdownSearch extends StatelessWidget {
  final List<Map<String, dynamic>> surahList;
  final void Function(int id) onSurahSelected;

  const SurahDropdownSearch({
    super.key,
    required this.surahList,
    required this.onSurahSelected,
  });

  static const Color backgroundColor = Color(0xFF202125);
  static const Color dropdownFillColor = Color(0xFF2C2C2E);

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<Map<String, dynamic>>(
      items: surahList,
      itemAsString: (surah) =>
          '${surah["id"]}. ${surah["transliteration"] ?? surah["translation"] ?? surah["name"]}',
      popupProps: PopupProps.dialog(
        showSearchBox: true,
        dialogProps: DialogProps(
          backgroundColor: backgroundColor,
        ),
        searchFieldProps: TextFieldProps(
          decoration: InputDecoration(
            hintText: "Search Surah...",
            hintStyle: const TextStyle(color: Colors.white60),
            filled: true,
            fillColor: dropdownFillColor,
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.greenAccent.withOpacity(0.5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.greenAccent.withOpacity(0.5)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.greenAccent, width: 2),
            ),
          ),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          filled: true,
          fillColor: backgroundColor,
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.greenAccent),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      dropdownBuilder: (context, selectedItem) {
        if (selectedItem == null) {
          return const Text("Search...", style: TextStyle(color: Colors.white54));
        }
        final name = selectedItem["transliteration"] ??
            selectedItem["translation"] ??
            selectedItem["name"] ??
            '';
        return Text(
          '${selectedItem["id"]}. $name',
          style: const TextStyle(color: Colors.white),
        );
      },
      onChanged: (selected) {
        if (selected != null) {
          onSurahSelected(selected["id"]);
        }
      },
    );
  }
}
