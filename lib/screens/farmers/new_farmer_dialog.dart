import 'package:alert_system_for_gaps/core/constants/color_constants.dart';
import 'package:alert_system_for_gaps/core/widgets/app_button_widget.dart';
import 'package:alert_system_for_gaps/core/widgets/input_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:widget_loading/widget_loading.dart';

class NewFarmerDialog extends StatefulWidget {
  const NewFarmerDialog({super.key});

  @override
  State<NewFarmerDialog> createState() => _NewFarmerDialogState();
}

class _NewFarmerDialogState extends State<NewFarmerDialog> {
  TextEditingController nameController = TextEditingController();
  TextEditingController sizeController = TextEditingController();
  TextEditingController locationController = TextEditingController();

  int _selectedClass = 0;
  String number = "";
  List<String> classes = [
    "A",
    "B",
    "C",
    "D",
    "E",
  ];
  bool loading = false;

  Future<void> saveFarmerDetails(BuildContext context) async {
    try {
      setState(() {
        loading = true;
      });
      final farmerSnapshot = await FirebaseFirestore.instance
          .collection('farmers')
          .where('number', isEqualTo: number)
          .get();

      if (farmerSnapshot.docs.isEmpty) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? id = prefs.getString("id");

        await FirebaseFirestore.instance.collection('farmers').add({
          'name': nameController.text.trim(),
          'location': locationController.text.trim(),
          'number': number,
          'size': sizeController.text.trim(),
          'class': classes[_selectedClass],
          "officerId": id
        });

        setState(() {
          loading = false;
        });

        showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              title: Text(
                "Success",
                style: TextStyle(color: Colors.green),
              ),
              content: Text('Farmer Added'),
            );
          },
        );
      } else {
        setState(() {
          loading = false;
        });
        showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              title: Text("Error"),
              content: Text('Phone number already belongs to another farmer'),
            );
          },
        );
      }

      setState(() {
        loading = false;
      });
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        loading = false;
      });
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Error"),
            content: Text('Failed to save user details. Error: $e'),
          );
        },
      );
    }
  }

  bool containsOnlyNumbersAndPlus(String input) {
    // Define a regular expression that matches strings containing only digits and the '+' character
    final regex = RegExp(r'^[0-9+]+$');

    // Test the input string against the regex and return the result
    return regex.hasMatch(input);
  }

  bool containsOnlyAlphabets(String input) {
    final RegExp alphabetRegex = RegExp(r'^[a-zA-Z]+$');
    return alphabetRegex.hasMatch(input);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return AlertDialog(
      backgroundColor: bgColor,
      contentPadding: const EdgeInsets.all(0),
      content: SizedBox(
        width: 750,
        child: Stack(
          children: <Widget>[
            Positioned(
              left: -34,
              top: 181.0,
              child: SvgPicture.string(
                // Group 3178
                '<svg viewBox="-34.0 181.0 99.0 99.0" ><path transform="translate(-34.0, 181.0)" d="M 74.25 0 L 99 49.5 L 74.25 99 L 24.74999618530273 99 L 0 49.49999618530273 L 24.7500057220459 0 Z" fill="none" stroke="#ffffff" stroke-width="1" stroke-opacity="0.25" stroke-miterlimit="4" stroke-linecap="butt" /><path transform="translate(-26.57, 206.25)" d="M 0 0 L 42.07500076293945 16.82999992370605 L 84.15000152587891 0" fill="none" stroke="#ffffff" stroke-width="1" stroke-opacity="0.25" stroke-miterlimit="4" stroke-linecap="butt" /><path transform="translate(15.5, 223.07)" d="M 0 56.42999649047852 L 0 0" fill="none" stroke="#ffffff" stroke-width="1" stroke-opacity="0.25" stroke-miterlimit="4" stroke-linecap="butt" /></svg>',
                width: 99.0,
                height: 99.0,
              ),
            ),
            Positioned(
              right: -52,
              top: 45.0,
              child: SvgPicture.string(
                // Group 3177
                '<svg viewBox="288.0 45.0 139.0 139.0" ><path transform="translate(288.0, 45.0)" d="M 104.25 0 L 139 69.5 L 104.25 139 L 34.74999618530273 139 L 0 69.5 L 34.75000762939453 0 Z" fill="none" stroke="#ffffff" stroke-width="1" stroke-opacity="0.25" stroke-miterlimit="4" stroke-linecap="butt" /><path transform="translate(298.42, 80.45)" d="M 0 0 L 59.07500076293945 23.63000106811523 L 118.1500015258789 0" fill="none" stroke="#ffffff" stroke-width="1" stroke-opacity="0.25" stroke-miterlimit="4" stroke-linecap="butt" /><path transform="translate(357.5, 104.07)" d="M 0 79.22999572753906 L 0 0" fill="none" stroke="#ffffff" stroke-width="1" stroke-opacity="0.25" stroke-miterlimit="4" stroke-linecap="butt" /></svg>',
                width: 139.0,
                height: 139.0,
              ),
            ),
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 550),
                    child: CircularWidgetLoading(
                      loading: loading,
                      dotColor: Colors.green,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 16,
                          ),
                          richText(23.12),
                          const SizedBox(
                            height: 20,
                          ),
                          InputWidget(
                            kController: nameController,
                            keyboardType: TextInputType.text,
                            onSaved: (String? value) {},
                            onChanged: (String? value) {},
                            validator: (String? value) {
                              return (value != null && value.contains('@'))
                                  ? 'Do not use the @ char.'
                                  : null;
                            },
                            topLabel: "Name",
                            hintText: "Enter Farmer Name",
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          InputWidget(
                            kController: locationController,
                            keyboardType: TextInputType.text,
                            onSaved: (String? value) {},
                            onChanged: (String? value) {},
                            validator: (String? value) {
                              return (value != null && value.contains('@'))
                                  ? 'Do not use the @ char.'
                                  : null;
                            },
                            topLabel: "Location",
                            hintText: "Enter Farm location",
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          InputWidget(
                            kController: sizeController,
                            keyboardType: TextInputType.text,
                            onSaved: (String? value) {},
                            onChanged: (String? value) {},
                            validator: (String? value) {
                              return (value != null && value.contains('@'))
                                  ? 'Do not use the @ char.'
                                  : null;
                            },
                            topLabel: "Size",
                            hintText: "Enter Farm Size",
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          IntlPhoneField(
                            initialCountryCode: 'GH',
                            decoration: InputDecoration(
                              fillColor: const Color.fromRGBO(74, 77, 84, 0.2),
                              labelText: 'Farmer Phone Number',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4.0),
                                borderSide: const BorderSide(),
                              ),
                            ),
                            languageCode: "en",
                            onChanged: (phone) {
                              setState(() {
                                number = phone.completeNumber;
                              });
                              print(number);
                            },
                            onCountryChanged: (country) {
                              print('Country changed to: ${country.name}');
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Farm Class",
                            style: GoogleFonts.montserrat(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            height: 60,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: classes.toList().length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedClass = index;
                                      print(classes[_selectedClass]);
                                    });
                                  },
                                  child: AnimatedContainer(
                                    width: 50,
                                    duration: Duration(milliseconds: 500),
                                    margin: EdgeInsets.only(right: 10),
                                    decoration: BoxDecoration(
                                        color: _selectedClass == index
                                            ? Colors.green[800]
                                            : Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(10),
                                        shape: BoxShape.rectangle),
                                    height: 40,
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          classes.toList()[index],
                                          style: TextStyle(
                                              color: _selectedClass == index
                                                  ? Colors.white
                                                  : Colors.black,
                                              fontSize: 15),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(
                            height: 50,
                          ),
                          WiperLoading(
                            loading: loading,
                            wiperColor: Colors.green,
                            child: AppButton(
                              type: ButtonType.PRIMARY,
                              text: 'Proceed',
                              onPressed: () async {
                                if (!containsOnlyAlphabets(nameController.text)){
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return const AlertDialog(
                                          title: Text("Invalid Name"),
                                          content: Text(
                                              'Please enter a name'),
                                        );
                                      });
                                } else if(number.length < 13) {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return const AlertDialog(
                                          title: Text("Invalid Number"),
                                          content: Text(
                                              'Please enter a valid phone number'),
                                        );
                                      });
                                } else if (nameController.text.isEmpty ||
                                    locationController.text.isEmpty ||
                                    sizeController.text.isEmpty) {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return const AlertDialog(
                                          title:
                                              Text("All fields are required"),
                                          content:
                                              Text('Please fill all fields'),
                                        );
                                      });
                                }else if( !containsOnlyNumbersAndPlus(number)){
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return const AlertDialog(
                                          title: Text("Input Error"),
                                          content:
                                          Text("Phone number should only contain numbers"),
                                        );
                                      });
                                } else {
                                  saveFarmerDetails(
                                    context,
                                  );
                                }
                              },
                            ),
                          ),
                          const SizedBox(
                            height: 50,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget richText(double fontSize) {
    return Text.rich(
      TextSpan(
        style: GoogleFonts.inter(
          color: Colors.white,
          letterSpacing: 1.999999953855673,
        ),
        children: const [
          TextSpan(
            text: 'Add new ',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          TextSpan(
            text: 'Farmer',
            style: TextStyle(
              color: Color(0xFFFE9879),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
