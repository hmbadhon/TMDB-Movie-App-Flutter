import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:movie_app/sheared/custom_loader.dart';
import 'package:movie_app/sheared/default_btn.dart';
import 'package:movie_app/sheared/input_form_widget.dart';
import 'package:movie_app/utils/constants.dart';
import 'package:movie_app/utils/size_config.dart';
import 'package:movie_app/view/home_screen/home_screen.dart';

import '../../main.dart';

class LoginScreen extends StatelessWidget {
  static const routeName = 'login_screen';
  LoginScreen({Key? key}) : super(key: key);
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: Image.asset(
              kImageDir + 'border_login.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 0,
            child: SizedBox(
              width: SizeConfig.screenWidth,
              height: SizeConfig.screenWidth / 1.8,
              child: Image.asset(
                kImageDir + 'bottom_login.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: getProportionateScreenWidth(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: getProportionateScreenHeight(20),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Hero(
                      tag: 'logo',
                      child: SizedBox(
                          width: SizeConfig.screenWidth / 2,
                          child: Image.asset('${kImageDir}logo.png')),
                    ),
                  ),
                  SizedBox(
                    height: getProportionateScreenHeight(30),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: getProportionateScreenHeight(20),
                    ),
                    child: Text(
                      'Login',
                      style: kHeadLine,
                    ),
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        InputFormWidget(
                          fieldController: _emailController,
                          labelText: 'Email Address',
                          icon: Icons.email,
                          fillColor: kOrdinaryColor2,
                          keyType: TextInputType.emailAddress,
                          validation: (value) {
                            if (value.isEmpty) {
                              return kEmailNullError;
                            } else if (!emailValidatorRegExp.hasMatch(value)) {
                              return kInvalidEmailError;
                            }
                            return null;
                          },
                        ),
                        InputFormWidget(
                          fieldController: _passController,
                          labelText: 'Password',
                          icon: Icons.lock,
                          fillColor: kOrdinaryColor2,
                          keyType: TextInputType.visiblePassword,
                          isProtected: true,
                          validation: (value) {
                            if (value.isEmpty) {
                              return kPassNullError;
                            } else if (value.length < 4) {
                              return kShortPassError;
                            }
                            return null;
                          },
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: getProportionateScreenHeight(35),
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            child: DefaultBtn(
                              title: 'Login',
                              onPress: () async {
                                if (_formKey.currentState!.validate()) {
                                  try {
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (_) => const CustomLoader(
                                        color: kWhiteColor,
                                      ),
                                    );
                                    await _auth.signInWithEmailAndPassword(
                                      email: _emailController.text,
                                      password: _passController.text,
                                    );
                                    Navigator.pop(context);
                                    prefs!.setBool('token', true);
                                    Navigator.pushNamedAndRemoveUntil(context,
                                        HomeScreen.routeName, (route) => false);
                                    _passController.clear();
                                    _emailController.clear();
                                  } on FirebaseAuthException catch (e) {
                                    if (e.code == 'user-not-found') {
                                      Navigator.pop(context);
                                      Get.snackbar(
                                          'No user found for that email.', '',
                                          colorText: kBlackColor);
                                      log('No user found for that email.');
                                    } else if (e.code == 'wrong-password') {
                                      Navigator.pop(context);
                                      Get.snackbar(
                                          'Wrong password provided for that user.',
                                          '',
                                          colorText: kBlackColor);
                                      log('Wrong password provided for that user.');
                                    }
                                  }
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
