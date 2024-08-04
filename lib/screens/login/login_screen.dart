import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:widget_loading/widget_loading.dart';
import '../../core/constants/color_constants.dart';
import '../../core/widgets/app_button_widget.dart';
import '../../core/widgets/input_widget.dart';
import '../home/home_screen.dart';
import 'components/slider_widget.dart';

class Login extends StatefulWidget {
  Login({required this.title});
  final String title;
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  var tweenLeft = Tween<Offset>(begin: Offset(2, 0), end: Offset(0, 0))
      .chain(CurveTween(curve: Curves.ease));
  var tweenRight = Tween<Offset>(begin: Offset(0, 0), end: Offset(2, 0))
      .chain(CurveTween(curve: Curves.ease));

  AnimationController? _animationController;
  TextEditingController nameController = TextEditingController();
  TextEditingController idController = TextEditingController();

  var _isMoved = false;
  String number = "";
  bool _codeSent = false;
  String otp = "";
  bool loading = false;
  bool isChecked = false;
  String generatedOTP = "";
  bool _isButtonDisabled = false;
  int _countdown = 60;
  Timer? _timer;

  bool _isValidPhoneNumber(String phoneNumber) {
    final RegExp regExp = RegExp(r'^\+[1-9]\d{1,14}$');
    return regExp.hasMatch(phoneNumber);
  }

  Future<void> getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? loggedIn = prefs.getString("logged");
    if (loggedIn == "true") {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ));
    }
  }

  void startTimer() {
    setState(() {
      _isButtonDisabled = true;
      _countdown = 60;
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_countdown == 0) {
        setState(() {
          _isButtonDisabled = false;
        });
        _timer?.cancel();
      } else {
        setState(() {
          _countdown--;
        });
      }
    });
  }

  void sendOTP(String phoneNumber) async {
    setState(() {
      loading = true;
    });
    generatedOTP = generateOTP();

    print(generatedOTP);

    const String apiKey = '0bce26ec-8f46-4640-951a-aba560e44e64';
    final String senderId = 'ASFGAPS';
    final String message = 'Your verification code for verifying your alert '
        'system for GAPS (ASFGAPS) account is: $generatedOTP \nDo not share this code with anyone.';
    final String url =
        'https://clientlogin.bulksmsgh.com/smsapi?key=$apiKey&to=$phoneNumber&msg=$message&sender_id=$senderId';

    print("//////requesting");

    try {
      final response = await http.get(Uri.parse(url));
      String result = response.body.trim();
      print(result);
      if (result == '1000') {
        setState(() {
          _codeSent = true;
          loading = false;
        });
        print('OTP sent successfully');
        startTimer();
      } else {
        setState(() {
          _codeSent = true;
          loading = false;
        });
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Error"),
              content: Text('Failed to send OTP. Error code: $result'),
            );
          },
        );
      }
    } catch (e) {
      print(e);
      setState(() {
        _codeSent = true;
        loading = false;
      });
      startTimer();
    }
  }

  void verifyOTP() async {
    if (otp == generatedOTP) {
      setState(() {
        loading = true;
      });

      print("fetching users");
      // Check if user with this number exists in Firestore
      try {
        final userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('phoneNumber', isEqualTo: number)
            .get();

        if (userSnapshot.docs.isNotEmpty) {
          print("user exists");
          final userData = userSnapshot.docs.first.data();
          final userName = userData['name'];
          final userId = userData['id'];
          final role = userData['role'];
          final phoneNumber = userData['phoneNumber'];

          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString("name", userName);
          prefs.setString("id", userId);
          prefs.setString("phoneNumber", phoneNumber);
          prefs.setString("role", role);
          prefs.setString("logged", "true");

          setState(() {
            loading = false;
          });

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(),
            ),
          );
        } else {
          setState(() {
            loading = false;
          });

          if (_isMoved) {
            _animationController!.reverse();
          } else {
            _animationController!.forward();
          }
          _isMoved = !_isMoved;
        }
      } catch (e) {
        print("error: $e");
        setState(() {
          loading = false;
        });
      }
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            title: Text("Invalid OTP"),
            content: Text('The entered OTP is incorrect'),
          );
        },
      );
    }
  }

  Future<void> saveUserDetails(BuildContext context, String name, String id,
      String phoneNumber, String role) async {
    try {
      setState(() {
        loading = true;
      });
      // Check if the ID exists in the 'ids' table and the roles match
      final idSnapshot = await FirebaseFirestore.instance
          .collection('ids')
          .where('id', isEqualTo: id)
          .where('role', isEqualTo: role)
          .get();

      if (idSnapshot.docs.isEmpty) {
        setState(() {
          loading = false;
        });
        showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              title: Text("Error"),
              content: Text('Please check ID and try again.'),
            );
          },
        );
        return;
      }

      // Check if the ID has already been used in the 'users' table
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('id', isEqualTo: id)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        setState(() {
          loading = false;
        });
        showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              title: Text("Error"),
              content: Text('ID has already been used.'),
            );
          },
        );
        return;
      }

      // If both checks pass, save the user details
      await FirebaseFirestore.instance.collection('users').add({
        'name': name,
        'id': id,
        'phoneNumber': phoneNumber,
        'role': role,
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();

      prefs.setString("name", name);
      prefs.setString("id", id);
      prefs.setString("phoneNumber", phoneNumber);
      prefs.setString("role", role);
      prefs.setString("logged", "true");

      setState(() {
        loading = false;
      });
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
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

  String generateOTP() {
    var rng = Random();
    return (rng.nextInt(9000) + 1000).toString();
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    getData();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    nameController.dispose();
    idController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: MediaQuery.of(context).size.width >= 1000
          ? Stack(
              fit: StackFit.loose,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width / 2,
                      color: Colors.white,
                      child: const SliderWidget(),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width / 2,
                      color: bgColor,
                      child: Center(
                        child: Card(
                          //elevation: 5,
                          color: bgColor,
                          child: Container(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, bottom: 10),
                            width: MediaQuery.of(context).size.width / 3,
                            height: MediaQuery.of(context).size.height / 1.1,
                            child: Column(
                              children: <Widget>[
                                const SizedBox(
                                  height: 10,
                                ),
                                Image.asset(
                                  "assets/logo/logo_icon.png",
                                  height: 50,
                                ),
                                richText(20),
                                SizedBox(height: 10.0),
                                Flexible(
                                  child: Stack(
                                    children: [
                                      SlideTransition(
                                        position: _animationController!
                                            .drive(tweenRight),
                                        child: Stack(
                                          fit: StackFit.loose,
                                          clipBehavior: Clip.none,
                                          children: [
                                            _loginScreen(context),
                                          ],
                                        ),
                                      ),
                                      SlideTransition(
                                        position: _animationController!
                                            .drive(tweenLeft),
                                        child: Stack(
                                          fit: StackFit.loose,
                                          clipBehavior: Clip.none,
                                          children: [
                                            _registerScreen(context),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            )
          : Container(
              height: MediaQuery.of(context).size.height,
              color: bgColor,
              child: Center(
                child: Card(
                  elevation: 5,
                  color: bgColor,
                  child: Container(
                    padding:
                        const EdgeInsets.only(left: 30, right: 30, bottom: 10),
                    width: MediaQuery.of(context).size.width / 1.4,
                    height: MediaQuery.of(context).size.height / 1.1,
                    child: Column(
                      children: <Widget>[
                        const SizedBox(
                          height: 10,
                        ),
                        Image.asset(
                          "assets/logo/logo_icon.png",
                          height: 50,
                        ),
                        richText(20),
                        const SizedBox(height: 10.0),
                        Flexible(
                          child: Stack(
                            children: [
                              SlideTransition(
                                position:
                                    _animationController!.drive(tweenRight),
                                child: Stack(
                                  fit: StackFit.loose,
                                  clipBehavior: Clip.none,
                                  children: [
                                    _loginScreen(context),
                                  ],
                                ),
                              ),
                              SlideTransition(
                                position:
                                    _animationController!.drive(tweenLeft),
                                child: Stack(
                                  fit: StackFit.loose,
                                  clipBehavior: Clip.none,
                                  children: [
                                    _registerScreen(context),
                                  ],
                                ),
                              ),
                            ],
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

  Container _registerScreen(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height - 0.0,
      ),
      child: SingleChildScrollView(
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 50,
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
                hintText: "Enter full Name",
              ),
              SizedBox(height: 8.0),
              InputWidget(
                kController: idController,
                keyboardType: TextInputType.text,
                onSaved: (String? value) {},
                onChanged: (String? value) {},
                validator: (String? value) {
                  return (value != null && value.contains('@'))
                      ? 'Do not use the @ char.'
                      : null;
                },
                topLabel: "ID",
                hintText: "Enter Staff Id",
              ),
              SizedBox(height: 24.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Checkbox(
                        value: isChecked,
                        onChanged: (bool? value) {
                          setState(() {
                            isChecked = value!;
                          });
                        },
                      ),
                      const Text("Extension officer")
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24.0),
              WiperLoading(
                loading: loading,
                child: AppButton(
                  type: ButtonType.PRIMARY,
                  text: "Sign Up",
                  onPressed: () async {
                    String role = isChecked ? "extension officer" : "admin";
                    await saveUserDetails(
                      context,
                      nameController.text,
                      idController.text,
                      number,
                      role,
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24.0),
            ],
          ),
        ),
      ),
    );
  }

  Container _loginScreen(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height - 0.0,
      ),
      child: SingleChildScrollView(
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 100.0),
              IntlPhoneField(
                initialCountryCode: 'GH',
                decoration: InputDecoration(
                  fillColor: const Color.fromRGBO(74, 77, 84, 0.2),
                  labelText: 'Phone Number',
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
              const SizedBox(height: 50.0),
              _codeSent == true
                  ? OtpTextField(
                      numberOfFields: 4,
                      borderColor: Color(0xFF512DA8),
                      showFieldAsBox: true,
                      fieldWidth: 38,
                      onCodeChanged: (String code) {},
                      onSubmit: (String verificationCode) {
                        setState(() {
                          otp = verificationCode;
                        });
                        print(otp);
                        verifyOTP();
                      },
                    )
                  : Container(),
              const SizedBox(height: 50.0),
              WiperLoading(
                loading: loading,
                child: AppButton(
                  type: ButtonType.PRIMARY,
                  text: _isButtonDisabled
                      ? 'Resend code in ($_countdown)'
                      : 'Send code',
                  onPressed: _isButtonDisabled
                      ? null
                      : () {
                          if (number.length < 13) {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return const AlertDialog(
                                    title: Text("Invalid Number"),
                                    content:
                                        Text('Please enter a valid phone number'),
                                  );
                                });
                          } else {
                            sendOTP(number);
                            startTimer();
                          }
                        },
                ),
              ),
              const SizedBox(height: 24.0),
            ],
          ),
        ),
      ),
    );
  }
}

Widget richText(double fontSize) {
  return Text.rich(
    TextSpan(
      style: GoogleFonts.inter(
        fontSize: 23.12,
        color: Colors.white,
        letterSpacing: 1.999999953855673,
      ),
      children: const [
        TextSpan(
          text: 'Alert system for ',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        TextSpan(
          text: 'GAPS',
          style: TextStyle(
            color: Color(0xFFFE9879),
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}

Future<void> insertIdsIntoFirestore() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final List<String> roles =
      List.generate(40, (index) => index < 20 ? 'admin' : 'extension officer');
  final Random random = Random();

  // Function to generate a single ID
  String generateId() {
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const numbers = '0123456789';
    String letterPart = '';
    String numberPart = '';

    for (int i = 0; i < 3; i++) {
      letterPart += letters[random.nextInt(letters.length)];
    }
    for (int i = 0; i < 7; i++) {
      numberPart += numbers[random.nextInt(numbers.length)];
    }
    return letterPart + numberPart;
  }

  // Generate and store the IDs
  for (int i = 0; i < 40; i++) {
    String id = generateId();
    String role = roles[i];

    try {
      await firestore.collection('ids').add({
        'id': id,
        'role': role,
      });
      print('Added ID: $id with role: $role');
    } catch (e) {
      print('Error adding ID: $id with role: $role - $e');
    }
  }
}
