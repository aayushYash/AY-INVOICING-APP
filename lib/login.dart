import 'dart:io';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginState();
  }
}

class LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    TextEditingController userName = TextEditingController();
    TextEditingController password = TextEditingController();
    bool loading = false;

    return WillPopScope(
      onWillPop: () async {
        return exit(0);
      },
      child: Scaffold(
        body: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipPath(
                //upper clippath with less height
                clipper: WaveClipper(), //set our custom wave clipper.
                child: Container(
                    padding: const EdgeInsets.only(bottom: 50),
                    color: Colors.amber,
                    height: 180,
                    alignment: Alignment.center,
                    child: const Text(
                      "",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    )),
              ),
              const SizedBox(
                height: 50,
              ),
              const Text(
                'Sign In',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                    fontSize: 42),
              ),
              const SizedBox(
                height: 50,
              ),
              Column(
                children: [
                  SizedBox(
                    width: 300,
                    child: TextFormField(
                      controller: userName,
                      decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.person),
                          labelText: 'Email',
                          contentPadding: EdgeInsets.zero,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          )),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: 300,
                    child: TextFormField(
                      controller: password,
                      decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.lock),
                          labelText: 'Password',
                          contentPadding: EdgeInsets.zero,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          )),
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  SizedBox(
                    width: 300,
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.amber)),
                      child: TextButton(
                        onPressed: () async {
                          FocusManager.instance.primaryFocus?.unfocus();

                          showDialog(
                            barrierDismissible: false,
                              context: context,
                              builder: (context) => const Center(
                                    child: CircularProgressIndicator(
                                    ),
                                  ));

                          await FirebaseAuth.instance
                              .signInWithEmailAndPassword(
                                  email: userName.text, password: password.text)
                              .onError((FirebaseAuthException e, stackTrace) {
                            Navigator.of(context).pop();

                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.amber,
                                content: Text(
                                  e.code
                                      .toString()
                                      .replaceAll('-', " ")
                                      .toUpperCase(),
                                  style: const TextStyle(color: Colors.black),
                                )));
                            throw 'error';
                          }).whenComplete((){
                            int i=0;
                            Navigator.of(context).pushNamed('/');
                          });

                        },
                        child: const Text(
                          'Login',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
        resizeToAvoidBottomInset: false,
      ),
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = new Path();
    path.lineTo(
        0, size.height); //start path with this if you are making at bottom

    var firstStart = Offset(size.width / 5, size.height);
    //fist point of quadratic bezier curve
    var firstEnd = Offset(size.width / 2.25, size.height - 50.0);
    //second point of quadratic bezier curve
    path.quadraticBezierTo(
        firstStart.dx, firstStart.dy, firstEnd.dx, firstEnd.dy);

    var secondStart =
        Offset(size.width - (size.width / 3.24), size.height - 105);
    //third point of quadratic bezier curve
    var secondEnd = Offset(size.width, size.height - 10);
    //fourth point of quadratic bezier curve
    path.quadraticBezierTo(
        secondStart.dx, secondStart.dy, secondEnd.dx, secondEnd.dy);

    path.lineTo(
        size.width, 0); //end with this path if you are making wave at bottom
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false; //if new instance have different instance than old instance
    //then you must return true;
  }
}
