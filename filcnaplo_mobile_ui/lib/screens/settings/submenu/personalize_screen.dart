// ignore_for_file: use_build_context_synchronously

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:filcnaplo/helpers/subject.dart';
import 'package:filcnaplo/models/settings.dart';
import 'package:filcnaplo/theme/colors/colors.dart';
import 'package:filcnaplo/utils/format.dart';
import 'package:filcnaplo_kreta_api/models/subject.dart';
import 'package:filcnaplo_kreta_api/providers/absence_provider.dart';
import 'package:filcnaplo_kreta_api/providers/grade_provider.dart';
import 'package:filcnaplo_kreta_api/providers/timetable_provider.dart';
import 'package:filcnaplo_mobile_ui/common/panel/panel_button.dart';
import 'package:filcnaplo_mobile_ui/common/splitted_panel/splitted_panel.dart';
import 'package:filcnaplo_mobile_ui/screens/settings/settings_helper.dart';
import 'package:filcnaplo_mobile_ui/screens/settings/submenu/edit_subject.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:provider/provider.dart';
import 'package:filcnaplo_mobile_ui/screens/settings/settings_screen.i18n.dart';

class MenuPersonalizeSettings extends StatelessWidget {
  const MenuPersonalizeSettings({
    super.key,
    this.borderRadius = const BorderRadius.vertical(
        top: Radius.circular(4.0), bottom: Radius.circular(4.0)),
  });

  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return PanelButton(
      onPressed: () => Navigator.of(context, rootNavigator: true).push(
        CupertinoPageRoute(
            builder: (context) => const PersonalizeSettingsScreen()),
      ),
      title: Text("personalization".i18n),
      leading: Icon(
        FeatherIcons.droplet,
        size: 22.0,
        color: AppColors.of(context).text.withOpacity(0.95),
      ),
      trailing: Icon(
        FeatherIcons.chevronRight,
        size: 22.0,
        color: AppColors.of(context).text.withOpacity(0.95),
      ),
      borderRadius: borderRadius,
    );
  }
}

class PersonalizeSettingsScreen extends StatefulWidget {
  const PersonalizeSettingsScreen({super.key});

  @override
  PersonalizeSettingsScreenState createState() =>
      PersonalizeSettingsScreenState();
}

class PersonalizeSettingsScreenState extends State<PersonalizeSettingsScreen>
    with SingleTickerProviderStateMixin {
  late SettingsProvider settingsProvider;

  late AnimationController _hideContainersController;

  late List<GradeSubject> editedSubjects;
  late List<GradeSubject> otherSubjects;

  late List<Widget> tiles;

  @override
  void initState() {
    super.initState();

    editedSubjects = Provider.of<GradeProvider>(context, listen: false)
        .grades
        .where((e) => e.teacher.isRenamed || e.subject.isRenamed)
        .map((e) => e.subject)
        .toSet()
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    otherSubjects = Provider.of<GradeProvider>(context, listen: false)
        .grades
        .where((e) => !e.teacher.isRenamed && !e.subject.isRenamed)
        .map((e) => e.subject)
        .toSet()
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    _hideContainersController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
  }

  void buildSubjectTiles() {
    List<Widget> subjectTiles = [];

    var i = 0;

    for (var s in editedSubjects) {
      Widget widget = PanelButton(
        onPressed: () => Navigator.of(context, rootNavigator: true).push(
          CupertinoPageRoute(
            builder: (context) => EditSubjectScreen(subject: s),
          ),
        ),
        title: Text(
          (s.isRenamed && settingsProvider.renamedSubjectsEnabled
                  ? s.renamedTo
                  : s.name.capital()) ??
              '',
          style: TextStyle(
            color: AppColors.of(context).text.withOpacity(.95),
            fontStyle: settingsProvider.renamedSubjectsItalics
                ? FontStyle.italic
                : FontStyle.normal,
          ),
        ),
        leading: Icon(
          SubjectIcon.resolveVariant(context: context, subject: s),
          size: 22.0,
          color: AppColors.of(context).text.withOpacity(.95),
        ),
        trailing: Icon(
          FeatherIcons.chevronRight,
          size: 22.0,
          color: AppColors.of(context).text.withOpacity(0.95),
        ),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(i == 0 ? 12.0 : 4.0),
          bottom: Radius.circular(i + 1 == editedSubjects.length ? 12.0 : 4.0),
        ),
      );

      i += 1;
      subjectTiles.add(widget);
    }

    tiles = subjectTiles;
  }

  @override
  Widget build(BuildContext context) {
    settingsProvider = Provider.of<SettingsProvider>(context);

    String themeModeText = {
          ThemeMode.light: "light".i18n,
          ThemeMode.dark: "dark".i18n,
          ThemeMode.system: "system".i18n
        }[settingsProvider.theme] ??
        "?";

    buildSubjectTiles();

    return AnimatedBuilder(
      animation: _hideContainersController,
      builder: (context, child) => Opacity(
        opacity: 1 - _hideContainersController.value,
        child: Scaffold(
          appBar: AppBar(
            surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
            leading: BackButton(color: AppColors.of(context).text),
            title: Text(
              "personalization".i18n,
              style: TextStyle(color: AppColors.of(context).text),
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
              child: Column(
                children: [
                  // app theme
                  SplittedPanel(
                    padding: const EdgeInsets.only(top: 8.0),
                    cardPadding: const EdgeInsets.all(4.0),
                    isSeparated: true,
                    children: [
                      PanelButton(
                        onPressed: () {
                          SettingsHelper.theme(context);
                          setState(() {});
                        },
                        title: Text("theme".i18n),
                        leading: Icon(
                          FeatherIcons.sun,
                          size: 22.0,
                          color: AppColors.of(context).text.withOpacity(0.95),
                        ),
                        trailing: Text(
                          themeModeText,
                          style: const TextStyle(fontSize: 14.0),
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12.0),
                          bottom: Radius.circular(12.0),
                        ),
                      ),
                    ],
                  ),
                  // color magic shit
                  SplittedPanel(
                    padding: const EdgeInsets.only(top: 9.0),
                    cardPadding: const EdgeInsets.all(4.0),
                    isSeparated: true,
                    children: [
                      PanelButton(
                        padding: const EdgeInsets.only(left: 14.0, right: 14.0),
                        onPressed: () async {
                          await _hideContainersController.forward();
                          SettingsHelper.accentColor(context);
                          setState(() {});
                          _hideContainersController.reset();
                        },
                        title: Text(
                          "color".i18n,
                          style: TextStyle(
                            color: AppColors.of(context).text.withOpacity(.95),
                          ),
                        ),
                        leading: Icon(
                          FeatherIcons.droplet,
                          size: 22.0,
                          color: AppColors.of(context).text.withOpacity(.95),
                        ),
                        trailing: Container(
                          width: 12.0,
                          height: 12.0,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12.0),
                          bottom: Radius.circular(12.0),
                        ),
                      ),
                    ],
                  ),
                  // change subject icons
                  SplittedPanel(
                    padding: const EdgeInsets.only(top: 9.0),
                    cardPadding: const EdgeInsets.all(4.0),
                    isSeparated: true,
                    children: [
                      PanelButton(
                        onPressed: () {
                          SettingsHelper.iconPack(context);
                        },
                        title: Text(
                          "icon_pack".i18n,
                          style: TextStyle(
                            color: AppColors.of(context).text.withOpacity(.95),
                          ),
                        ),
                        leading: Icon(
                          FeatherIcons.grid,
                          size: 22.0,
                          color: AppColors.of(context).text.withOpacity(.95),
                        ),
                        trailing: Text(
                          settingsProvider.iconPack.name.capital(),
                          style: const TextStyle(fontSize: 14.0),
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12.0),
                          bottom: Radius.circular(12.0),
                        ),
                      ),
                    ],
                  ),
                  // grade colors
                  SplittedPanel(
                    padding: const EdgeInsets.only(top: 9.0),
                    cardPadding: const EdgeInsets.all(4.0),
                    isSeparated: true,
                    children: [
                      PanelButton(
                        onPressed: () {
                          SettingsHelper.gradeColors(context);
                          setState(() {});
                        },
                        title: Text(
                          "grade_colors".i18n,
                          style: TextStyle(
                            color: AppColors.of(context).text.withOpacity(.95),
                          ),
                        ),
                        leading: Icon(
                          FeatherIcons.star,
                          size: 22.0,
                          color: AppColors.of(context).text.withOpacity(.95),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            5,
                            (i) => Container(
                              margin: const EdgeInsets.only(left: 2.0),
                              width: 12.0,
                              height: 12.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: settingsProvider.gradeColors[i],
                              ),
                            ),
                          ),
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12.0),
                          bottom: Radius.circular(12.0),
                        ),
                      ),
                    ],
                  ),
                  // rename subjects
                  SplittedPanel(
                    padding: const EdgeInsets.only(top: 9.0),
                    cardPadding: const EdgeInsets.all(4.0),
                    isSeparated: true,
                    children: [
                      PanelButton(
                        padding: const EdgeInsets.only(left: 14.0, right: 6.0),
                        onPressed: () async {
                          settingsProvider.update(
                              renamedSubjectsEnabled:
                                  !settingsProvider.renamedSubjectsEnabled);
                          await Provider.of<GradeProvider>(context,
                                  listen: false)
                              .convertBySettings();
                          await Provider.of<TimetableProvider>(context,
                                  listen: false)
                              .convertBySettings();
                          await Provider.of<AbsenceProvider>(context,
                                  listen: false)
                              .convertBySettings();

                          setState(() {});
                        },
                        title: Text(
                          "rename_subjects".i18n,
                          style: TextStyle(
                            color: AppColors.of(context).text.withOpacity(
                                settingsProvider.renamedSubjectsEnabled
                                    ? .95
                                    : .25),
                          ),
                        ),
                        leading: Icon(
                          FeatherIcons.penTool,
                          size: 22.0,
                          color: AppColors.of(context).text.withOpacity(
                              settingsProvider.renamedSubjectsEnabled
                                  ? .95
                                  : .25),
                        ),
                        trailing: Switch(
                          onChanged: (v) async {
                            settingsProvider.update(renamedSubjectsEnabled: v);
                            await Provider.of<GradeProvider>(context,
                                    listen: false)
                                .convertBySettings();
                            await Provider.of<TimetableProvider>(context,
                                    listen: false)
                                .convertBySettings();
                            await Provider.of<AbsenceProvider>(context,
                                    listen: false)
                                .convertBySettings();

                            setState(() {});
                          },
                          value: settingsProvider.renamedSubjectsEnabled,
                          activeColor: Theme.of(context).colorScheme.secondary,
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12.0),
                          bottom: Radius.circular(12.0),
                        ),
                      ),
                    ],
                  ),
                  // rename teachers
                  SplittedPanel(
                    padding: const EdgeInsets.only(top: 9.0),
                    cardPadding: const EdgeInsets.all(4.0),
                    isSeparated: true,
                    children: [
                      PanelButton(
                        padding: const EdgeInsets.only(left: 14.0, right: 6.0),
                        onPressed: () async {
                          settingsProvider.update(
                              renamedTeachersEnabled:
                                  !settingsProvider.renamedTeachersEnabled);
                          await Provider.of<GradeProvider>(context,
                                  listen: false)
                              .convertBySettings();
                          await Provider.of<TimetableProvider>(context,
                                  listen: false)
                              .convertBySettings();
                          await Provider.of<AbsenceProvider>(context,
                                  listen: false)
                              .convertBySettings();

                          setState(() {});
                        },
                        title: Text(
                          "rename_teachers".i18n,
                          style: TextStyle(
                            color: AppColors.of(context).text.withOpacity(
                                settingsProvider.renamedTeachersEnabled
                                    ? .95
                                    : .25),
                          ),
                        ),
                        leading: Icon(
                          FeatherIcons.user,
                          size: 22.0,
                          color: AppColors.of(context).text.withOpacity(
                              settingsProvider.renamedTeachersEnabled
                                  ? .95
                                  : .25),
                        ),
                        trailing: Switch(
                          onChanged: (v) async {
                            settingsProvider.update(renamedTeachersEnabled: v);
                            await Provider.of<GradeProvider>(context,
                                    listen: false)
                                .convertBySettings();
                            await Provider.of<TimetableProvider>(context,
                                    listen: false)
                                .convertBySettings();
                            await Provider.of<AbsenceProvider>(context,
                                    listen: false)
                                .convertBySettings();

                            setState(() {});
                          },
                          value: settingsProvider.renamedTeachersEnabled,
                          activeColor: Theme.of(context).colorScheme.secondary,
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12.0),
                          bottom: Radius.circular(12.0),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 18.0,
                  ),
                  SplittedPanel(
                    title: Text('subjects'.i18n),
                    padding: EdgeInsets.zero,
                    cardPadding: const EdgeInsets.all(4.0),
                    children: tiles,
                  ),
                  const SizedBox(
                    height: 9.0,
                  ),
                  SplittedPanel(
                    padding: EdgeInsets.zero,
                    cardPadding: const EdgeInsets.all(3.0),
                    hasBorder: true,
                    isTransparent: true,
                    children: [
                      DropdownButton2(
                        items: otherSubjects
                            .map((item) => DropdownMenuItem<String>(
                                  value: item.id,
                                  child: Text(
                                    item.name,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.of(context).text,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                        onChanged: (String? v) {
                          Navigator.of(context, rootNavigator: true).push(
                            CupertinoPageRoute(
                              builder: (context) => EditSubjectScreen(
                                subject:
                                    otherSubjects.firstWhere((e) => e.id == v),
                              ),
                            ),
                          );
                          // _subjectName.text = "";
                        },
                        iconSize: 14,
                        iconEnabledColor: AppColors.of(context).text,
                        iconDisabledColor: AppColors.of(context).text,
                        underline: const SizedBox(),
                        itemHeight: 40,
                        itemPadding: const EdgeInsets.only(left: 14, right: 14),
                        buttonWidth: 50,
                        dropdownWidth: 300,
                        dropdownPadding: null,
                        buttonDecoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        dropdownDecoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        dropdownElevation: 8,
                        scrollbarRadius: const Radius.circular(40),
                        scrollbarThickness: 6,
                        scrollbarAlwaysShow: true,
                        offset: const Offset(-10, -10),
                        buttonSplashColor: Colors.transparent,
                        customButton: PanelButton(
                          title: Text(
                            "select_subject".i18n,
                            style: TextStyle(
                              color:
                                  AppColors.of(context).text.withOpacity(.95),
                            ),
                          ),
                          leading: Icon(
                            FeatherIcons.plus,
                            size: 22.0,
                            color: AppColors.of(context).text.withOpacity(.95),
                          ),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12.0),
                            bottom: Radius.circular(12.0),
                          ),
                        ),
                      ),
                    ],
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
